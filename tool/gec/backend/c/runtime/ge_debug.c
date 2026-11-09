/*
	description:

		"C functions used for debugging"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"
*/

#ifndef GE_DEBUG_C
#define GE_DEBUG_C
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifdef GE_DEBUG_MODE

#ifndef GE_DEBUG_H
#include "ge_debug.h"
#endif

#ifndef GE_THREAD_H
#include "ge_thread.h"
#endif

#ifndef GE_GC_H
#include "ge_gc.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <sys/stat.h>

#if defined(_MSC_VER)
#include <crtdbg.h>  // Required for _set_invalid_parameter_handler
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Pipes to communicate with the VS Code Eiffel debugger adapter. */
static FILE* GE_debug_in = NULL;
static FILE* GE_debug_out = NULL;
#define GOBO_DEBUG_PIPE_IN "GOBO_DEBUG_PIPE_IN"
#define GOBO_DEBUG_PIPE_OUT "GOBO_DEBUG_PIPE_OUT"

/* Mutex to access debug data. */
static EIF_MUTEX_TYPE* GE_debug_mutex = 0;

/*
 * Has the VS Code Eiffel debugger adapter indicated that
 * it is OK now to run the Eiffel program?
 */
static int GE_debug_configuration_done = 0;

/* Debugger status. */
static int GE_debug_is_stopping = 0;
static int GE_debug_is_stopped = 0;
static uint32_t GE_debug_stopped_thread_id = 0;
static char* GE_debug_stopped_reason = 0;

/* Used to generate debugger thread ids. */
static uint32_t GE_debug_thread_counter = 0;

/* Eiffel execution threads. */
static GE_context* GE_debug_first_thread = 0;
static GE_context* GE_debug_last_thread = 0;

/*
 * Eiffel thread with a given debugger thread id.
 * Null if not found.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 */
static GE_context* GE_debug_thread_with_id(uint32_t a_id)
{
	GE_context* l_thread;
	GE_context* l_result = 0;

	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		if (l_thread->debug_thread_id == a_id) {
			l_result = l_thread;
			break;
		}
		l_thread = l_thread->next_thread;
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
	return l_result;
}

/*
 * Add `a_thread` to the list of Eiffel threads known by the debugger.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 */
void GE_debug_register_thread(GE_context* a_thread)
{
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	GE_debug_thread_counter++;
	a_thread->debug_thread_id = GE_debug_thread_counter;
	if (GE_debug_last_thread) {
		GE_debug_last_thread->next_thread = a_thread;
	} else {
		GE_debug_first_thread = a_thread;
	}
	GE_debug_last_thread = a_thread;
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
}

/*
 * Remove `a_thread` from the list of Eiffel threads known by the debugger.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 */
void GE_debug_remove_thread(GE_context* a_thread)
{
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (!GE_debug_first_thread) {
		/* No thread registered. */
	} else if (GE_debug_first_thread == a_thread) {
		GE_debug_first_thread = a_thread->next_thread;
		if (!GE_debug_first_thread) {
			GE_debug_last_thread = 0;
		}
	} else {
		GE_context* l_other_thread = GE_debug_first_thread;
		while (l_other_thread->next_thread && l_other_thread->next_thread != a_thread) {
			l_other_thread = l_other_thread->next_thread;
		}
		if (l_other_thread->next_thread == a_thread) {
			l_other_thread->next_thread = a_thread->next_thread;
			if (GE_debug_last_thread == a_thread) {
				GE_debug_last_thread = l_other_thread;
			}
		}
	}
	a_thread->next_thread = 0;
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
}

/*
 * Breakpoints for file `filename` if any, NULL otherwise.
 * 
 * Thread-safe.
 */
static GE_debug_file_breakpoints* GE_debug_breakpoints_for_file(char* filename)
{
	uint32_t i;
	for (i = 0; i < GE_debug_breakpoint_count; i++) {
		if (strcmp(GE_debug_breakpoints[i]->filename, filename) == 0) {
			return GE_debug_breakpoints[i];
		}
	}
	return 0;
}

/*
 * Breakpoint at line `line` in `breakpoints` if any, NULL otherwise.
 * 
 * Thread-safe.
 */
static GE_debug_breakpoint* GE_debug_breakpoint_at_line(uint32_t line, GE_debug_file_breakpoints* breakpoints)
{
	uint32_t i;
	uint32_t nb;
	nb = breakpoints->breakpoint_count;
	for (i = 0; i < nb; i++) {
		if (breakpoints->breakpoints[i]->first_line <= line && line <= breakpoints->breakpoints[i]->last_line) {
			return breakpoints->breakpoints[i];
		}
	}
	return 0;
}

/*
 * Disable all breakpoints in `breakpoints`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_disable_all_file_breakpoints(GE_debug_file_breakpoints* breakpoints)
{
	uint32_t i;
	uint32_t nb;
	nb = breakpoints->breakpoint_count;
	for (i = 0; i < nb; i++) {
		breakpoints->breakpoints[i]->enabled = 0;
	}
}

/*
 * Check whether all Eiffel threads are stopped or blocking.
 * `a_thread`, if not NULL, is expected to be stopped or blocking.
 * If all Eiffel threads are stopped or blocking, send notification
 * to VS Code Eiffel debugger adapter and return 1. Return 0 otherwise.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread other than `a_thread`.
 */
static int GE_unprotected_debug_check_and_send_all_stopped(GE_context* a_thread)
{
	int l_all_stopped = 1;
	GE_context* l_other_thread;

	if (!GE_debug_out) {
		return 0;
	}
	if (!GE_debug_is_stopping) {
		return 0;
	}
	l_other_thread = GE_debug_first_thread;
	while (l_other_thread) {
		if (l_other_thread != a_thread) {
			GE_mutex_lock((EIF_POINTER)l_other_thread->debug_mutex);
			if (!l_other_thread->is_stopped && !l_other_thread->is_blocking) {
				l_all_stopped = 0;
			}
			GE_mutex_unlock((EIF_POINTER)l_other_thread->debug_mutex);
		}
		if (!l_all_stopped) {
			break;
		}
		l_other_thread = l_other_thread->next_thread;
	}
	if (l_all_stopped) {
		GE_debug_is_stopping = 0;
		GE_debug_is_stopped = 1;
		if (!GE_debug_stopped_thread_id && GE_debug_first_thread) {
			GE_debug_stopped_thread_id = GE_debug_first_thread->debug_thread_id;
		}
		if (!GE_debug_stopped_reason) {
			GE_debug_stopped_reason = "pause";
		}
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"stopped\",\"body\":{\"reason\":\"%s\",\"threadId\":%d,\"allThreadsStopped\":true}}\n", GE_debug_stopped_reason, GE_debug_stopped_thread_id);
		fflush(GE_debug_out);
	}
	return l_all_stopped;
}

/*
 * Pause all Eiffel threads.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 */
static void GE_debug_pause_all()
{
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (!GE_debug_is_stopping && !GE_debug_is_stopped) {
		GE_debug_is_stopping = 1;
		GE_unprotected_debug_check_and_send_all_stopped(NULL);
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
}

/*
 * Continue execution of all Eiffel threads.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of each thread.
 */
static void GE_debug_continue_all()
{
	GE_context* l_thread;

	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	GE_debug_is_stopping = 0;
	GE_debug_is_stopped = 0;
	GE_debug_stopped_thread_id = 0;
	GE_debug_stopped_reason = 0;
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		l_thread->is_stopped = 0;
		GE_condition_variable_broadcast((EIF_POINTER)l_thread->debug_condition_variable);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		l_thread = l_thread->next_thread;
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
}

/*
 * Write escaped version of `s` to `GE_debug_out`.
 * 
 * Thread-safe.
 */
static void GE_debug_write_escaped_string(const char* s)
{
	int i = 0;

	if (!GE_debug_out) {
		return;
	}
	while (s[i]) {
		switch (s[i]) {
		case '\\':
			fputc('\\', GE_debug_out);
			fputc('\\', GE_debug_out);
			break;
		case '\"':
			fputc('\\', GE_debug_out);
			fputc('\"', GE_debug_out);
			break;
		default:
			fputc(s[i], GE_debug_out);
		}
		i++;
	}
}

/*
 * Write body of "threads" response to `GE_debug_out`.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 */
static void GE_debug_write_threads_body()
{
	GE_context* l_thread;
	uint32_t l_thread_id;
	uint32_t count = 0;

	if (!GE_debug_out) {
		return;
	}
	fprintf(GE_debug_out, "{\"threads\":[");
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		count++;
		if (count != 1) {
			fputc(',', GE_debug_out);
		}
		l_thread_id = l_thread->debug_thread_id;
		if (l_thread_id == 1) {
			fprintf(GE_debug_out, "{\"id\":1,\"name\":\"Main\"}");
		} else {
#ifdef GE_USE_SCOOP
			fprintf(GE_debug_out, "{\"id\":%d,\"name\":\"SCOOP processor %d\"}", l_thread_id, l_thread_id - 1);
#else
			fprintf(GE_debug_out, "{\"id\":%d,\"name\":\"Thread %d\"}", l_thread_id, l_thread_id - 1);
#endif
		}
		l_thread = l_thread->next_thread;
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
	fprintf(GE_debug_out, "]}");
}

/*
 * Write body of "stackTrace" response for thread `thread_id` to `GE_debug_out`.
 *
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of the thread `thread_id`.
 */
static void GE_debug_write_stack_trace_body(uint32_t thread_id)
{
	GE_context* l_thread;
	uint32_t count = 0;

	if (!GE_debug_out) {
		return;
	}
	l_thread = GE_debug_thread_with_id(thread_id);
	fprintf(GE_debug_out, "{\"stackFrames\":[");
	if (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		if (l_thread->is_stopped || l_thread->is_blocking) {
			GE_call* l_call = l_thread->call;
			while (l_call) {
				count++;
				if (count != 1) {
					fputc(',', GE_debug_out);
				}
				fprintf(GE_debug_out, "{\"id\":%d,\"name\":\"%s\",\"line\":%d,\"column\":%d,\"source\":{\"name\":\"%s\",\"path\":\"", count, l_call->feature_name, l_call->line, l_call->column, l_call->class_name);
				GE_debug_write_escaped_string(l_call->filename);
				fprintf(GE_debug_out, "\"}");
				l_call = l_call->caller;
				if (!l_call) {
					fprintf(GE_debug_out, ",\"presentationHint\":\"label\"");
				}
				fputc('}', GE_debug_out);
			}
		}
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
	}
	fprintf(GE_debug_out, "],\"totalFrames\":%d}", count);
}

/*
 * Read two bytes from `GE_debug_in` corresponding to the big endian
 * encoded size of the string, and then read that string and
 * return its value (null terminated).
 * The caller is reponsible for freeing its memory.
 * Return 0 if an error occured when reading from `GE_debug_in`.
 *
 * Thread-safe.
 */
static char* GE_debug_get_string()
{
	int b1;
	int b2;
	size_t size = 0;
	size_t count;
	size_t total = 0;
	char* buf;
	if (!GE_debug_in) {
		return 0;
	}
	b1 = fgetc(GE_debug_in);
	if (b1 == EOF) {
		return 0;
	}
	b2 = fgetc(GE_debug_in);
	if (b2 == EOF) {
		return 0;
	}
	size = ((uint16_t) b1 << 8) | (uint16_t) b2;
	/* Do not use `GE_malloc_atomic` to be sure that the GC
	 * does not get triggered and potentially calls `dispose`
	 * while the debugger is stopped.
	 */
	buf = (char*)malloc(size + 1);
	if (!buf) {
		return 0;
	}
	while (total != size) {
		count = fread(buf, 1, size, GE_debug_in);
		if (count <= 0) {
			free(buf);
			return 0;
		}
		total += count;
	}
	buf[size] = 0;
	return buf;
}

/* 
 * Receive a request from VS Code Eiffel debugger adapter
 * and process it.
 *
 * Thread-safe.
 */
static void GE_debug_receive_request()
{
	char* type;
	char* id;
	char* command;
	if (!GE_debug_in || !GE_debug_out) {
		return;
	}
	type = GE_debug_get_string();
	if (!type) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocalError\",\"body\":{},\"message\":\"'type' is missing in request\"}\n");
		fflush(GE_debug_out);
		return;
	}
	id = GE_debug_get_string();
	if (!id) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocalError\",\"body\":{},\"message\":\"'id' is missing in request\"}\n");
		fflush(GE_debug_out);
		free(type);
		return;
	}
	command = GE_debug_get_string();
	if (!command) {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'command' missing in request.\"}\n", id);
		fflush(GE_debug_out);
		free(type);
		free(id);
		return;
	} 
/* TODO */ fprintf(stderr, "command: %s\n", command);
	if(strcmp(command, "initialize") == 0) {
		/* Handle 'initialize'. */
		char* protocol_version;
		protocol_version = GE_debug_get_string();
		if (!protocol_version) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'protocolVersion' missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"protocolVersion\":1}}\n", id);
		free(protocol_version);
	} else if(strcmp(command, "configurationDone") == 0) {
		/* Handle 'configurationDone'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_debug_configuration_done = 1;
	} else if(strcmp(command, "setBreakpoints") == 0) {
		/* Handle 'setBreakPoints'. */
		char* source_path;
		char* bp_count_str;
		uint32_t bp_count;
		uint32_t i;
		char* bp_line_str;
		uint32_t bp_line;
		GE_debug_file_breakpoints* breakpoints;
		char missing_bp = 0;
		source_path = GE_debug_get_string();
		if (!source_path) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'sourcePath' missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		breakpoints = GE_debug_breakpoints_for_file(source_path);
		free(source_path);
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		if (breakpoints) {
			GE_unprotected_debug_disable_all_file_breakpoints(breakpoints);
		}
		bp_count_str = GE_debug_get_string();
		if (sscanf(bp_count_str, "%d", &bp_count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"breakpoint count missing in request '%s'.\"}\n", id, command);
			free(bp_count_str);
			GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
			goto GE_debug_receive_done;
		}
		free(bp_count_str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"breakpoints\":[", id);
		for (i = 0; i < bp_count; i++) {
			bp_line_str = GE_debug_get_string();
			if (sscanf(bp_line_str, "%d", &bp_line) != 1) {
				free(bp_line_str);
				missing_bp = 1;
				break;
			}
			free(bp_line_str);
			if (i != 0) {
				fprintf(GE_debug_out, ",");
			}
			if (breakpoints) {
				GE_debug_breakpoint* bp = GE_debug_breakpoint_at_line(bp_line, breakpoints);
				if (bp) {
					bp->enabled = 1;
					fprintf(GE_debug_out, "{\"id\":%d,\"verified\":true,\"line\":%d}",bp->id,bp->last_line);
				} else {
					fprintf(GE_debug_out, "{\"verified\":false,\"line\":%d,\"message\":\"No breakpoint compiled at this position.\"}", bp_line);
				}
			} else {
				fprintf(GE_debug_out, "{\"verified\":false,\"line\":%d,\"message\":\"No feature compiled in this file.\"}", bp_line);
			}
		}
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		fprintf(GE_debug_out, "]}}\n");
		if (missing_bp) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"breakpoint missing in request '%s'.\"}\n", id, command);
		}
	} else if(strcmp(command, "threads") == 0) {
		/* Handle 'threads'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":", id);
		GE_debug_write_threads_body();
		fprintf(GE_debug_out, "}\n");
	} else if(strcmp(command, "stackTrace") == 0) {
		/* Handle 'stackTrace'. */
		char* thread_id_str;
		uint32_t thread_id;
		thread_id_str = GE_debug_get_string();
		if (sscanf(thread_id_str, "%d", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(thread_id_str);
			goto GE_debug_receive_done;
		}
		free(thread_id_str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":", id);
		GE_debug_write_stack_trace_body(thread_id);
		fprintf(GE_debug_out, "}\n");
	} else if(strcmp(command, "continue") == 0) {
		/* Handle 'continue'. */
		GE_debug_continue_all();
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
	} else if(strcmp(command, "pause") == 0) {
		/* Handle 'pause'. */
		GE_debug_pause_all();
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
	} else {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"request '%s' not supported.\"}\n", id, command);
	}
GE_debug_receive_done:
	free(type);
	free(id);
	free(command);
	fflush(GE_debug_out);
}

/*
 * Receive requests from VS Code Eiffel debugger adapter
 * and process them.
 *
 * Thread-safe.
 */
static void GE_debug_receive_requests() {
	while (1) {
		GE_debug_receive_request();
	}
}


#if defined(_MSC_VER)
/* Handler to avoid a crash when calling `_fdopen` with an invalid file descriptor. */
void my_invalid_parameter_handler(const wchar_t* expression,
	const wchar_t* function, 
	const wchar_t* file, 
	unsigned int line, 
	uintptr_t pReserved)
{
    // Do nothing. This safely suppresses the crash and allows 
    // the calling CRT function to fail and return its error code.
}
#endif

/* Get pipe file descriptor from environment variable `name`. */
static int get_env_fd(const char *name, int *fd)
{
	const char *value = getenv(name);
	char *end;
	long n;

	if (value == NULL || *value == '\0') {
		return 0;
	}
	errno = 0;
	n = strtol(value, &end, 10);
	if (errno == ERANGE || *end != '\0' || end == value ||
		n < 0 || n > INT_MAX) {
		return 0;
	}
	*fd = (int) n;
	return 1;
}

/* Initialize debugging facilities. */
void GE_debug_init(GE_context* a_thread)
{
	int debug_pipe_in;
	int debug_pipe_out;

	GE_debug_mutex = (EIF_MUTEX_TYPE*)GE_mutex_create();
	GE_debug_register_thread(a_thread);

	if (get_env_fd(GOBO_DEBUG_PIPE_IN, &debug_pipe_in) && get_env_fd(GOBO_DEBUG_PIPE_OUT, &debug_pipe_out)) {
		GE_debug_in = NULL;
		GE_debug_out = NULL;
		struct stat buf;
#if defined(_MSC_VER)
		/* Register custom handler. */
		_invalid_parameter_handler oldHandler, newHandler;
		newHandler = my_invalid_parameter_handler;
		oldHandler = _set_invalid_parameter_handler(newHandler);
		/* Disable the default Windows crash dialog box popups (optional but helpful) */
		/* _CrtSetReportMode(_CRT_ASSERT, 0); */
#endif
		if (fstat(debug_pipe_in, &buf) == 0 && fstat(debug_pipe_out, &buf) == 0) {
#if defined(_MSC_VER)
			GE_debug_in = _fdopen(debug_pipe_in, "r");
#else
			GE_debug_in = fdopen(debug_pipe_in, "r");
#endif
			if (GE_debug_in) {
#if defined(_MSC_VER)
				GE_debug_out = _fdopen(debug_pipe_out, "w");
#else
				GE_debug_out = fdopen(debug_pipe_out, "w");
#endif
				if (!GE_debug_out) {
					fclose(GE_debug_in);
					GE_debug_in = NULL;
					GE_debug_out = NULL;
				}
			}
#if defined(_MSC_VER)
			newHandler = _set_invalid_parameter_handler(oldHandler);
#endif
		}
		if (GE_debug_in && GE_debug_out) {
			fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"started\",\"body\":{}}\n");
			fflush(GE_debug_out);
			while (!GE_debug_configuration_done) {
				GE_debug_receive_request();
			}
		}
		GE_debug_thread_create_with_attr(&GE_debug_receive_requests, 0);
	}
}

/* Action executed when breakpoint `a_breakpoint` is hit.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of each thread.
 */
void GE_debug_hit_breakpoint(GE_context* a_thread, GE_debug_breakpoint* a_breakpoint)
{
	if (!GE_debug_in || !GE_debug_out) {
		return;
	}
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (GE_debug_is_stopped || GE_debug_is_stopping || a_breakpoint->enabled) {
		GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
		if (!GE_debug_is_stopped) {
			if (!GE_debug_stopped_thread_id) {
				GE_debug_stopped_thread_id = a_thread->debug_thread_id;
				if (a_breakpoint->enabled) {
					GE_debug_stopped_reason = "breakpoint";
				} else {
					GE_debug_stopped_reason = "pause";
				}
			}
		}
		if (!GE_debug_is_stopped && !GE_debug_is_stopping) {
			GE_debug_is_stopping = 1;
		}
		if (!a_thread->is_stopped) {
			if (a_thread->call) {
				if (!GE_debug_is_stopped) {
					a_thread->call->line = a_breakpoint->last_line;
				}
				a_thread->call->column = 1;
			}
			a_thread->is_stopped = 1;
		}
		if (!GE_debug_is_stopped) {
			GE_unprotected_debug_check_and_send_all_stopped(a_thread);
		}
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
	} else {
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
	}
}

/*
 * Set `is_blocking` status of `a_thread`.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of each thread.
 */
void GE_debug_set_blocking(GE_context* a_thread, int a_value)
{
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	a_thread->is_blocking = a_value;
	if (a_value) {
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		if (GE_debug_is_stopped || GE_debug_is_stopping) {
			if (!a_thread->is_stopped) {
				if (a_thread->call) {
					a_thread->call->column = 1;
				}
				a_thread->is_stopped = 1;
			}
			if (!GE_debug_is_stopped) {
				GE_unprotected_debug_check_and_send_all_stopped(a_thread);
			}
			GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
			GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
			GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		} else {
			GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
			GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		}
	} else {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
	}
}

/*
 * Set position of `call`.
 * 
 * Thread-safe.
 * Protected by:
 * - Mutex of each `a_thread`.
 */
void GE_debug_set_call_position(GE_context* a_thread, GE_call* call, uint32_t line, uint32_t column)
{
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	call->line = line;
	call->column = column;
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
}

/*
 * Set class_name/filename of `call`.
 * 
 * Thread-safe.
 * Protected by:
 * - Mutex of each `a_thread`.
 */
void GE_debug_set_call_location(GE_context* a_thread, GE_call* call, char* class_name, char* filename)
{
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	call->class_name = class_name;
	call->filename = filename;
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
}

#ifdef __cplusplus
}
#endif

#endif
#endif
