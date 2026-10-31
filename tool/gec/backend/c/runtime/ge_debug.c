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

#ifndef GE_GC_H
#include "ge_gc.h"
#endif

#include <stdio.h>

#if defined(_MSC_VER)
#include <crtdbg.h>  // Required for _set_invalid_parameter_handler
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Pipes to communicate with the debug adapter. */
static FILE* GE_debug_in = NULL;
static FILE* GE_debug_out = NULL;

/*
 * Has the VS Code Eiffel debugger adapter indicated that
 * it is OK now to run the Eiffel program?
 */
static int GE_debug_configuration_done = 0;

/*
 * Has the VS Code Eiffel debugger adapter indicated that
 * it is OK now to continue executing the Eiffel program?
 */
static int GE_debug_continue = 0;

/*
 * Breakpoints for file `filename` if any, NULL otherwise.
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
 * Disable all breakpoints in `breakpoints`.
 */
static void GE_debug_disable_all_file_breakpoints(GE_debug_file_breakpoints* breakpoints)
{
	uint32_t i;
	uint32_t nb;
	nb = breakpoints->breakpoint_count;
	for (i = 0; i < nb; i++) {
		breakpoints->breakpoints[i]->enabled = 0;
	}
}

/*
 * Breakpoint at line `line` in `breakpoints` if any, NULL otherwise.
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
 * Write escaped version of `s` to `GE_debug_out`.
 */
static void GE_debug_write_escaped_string(const char* s)
{
	if (GE_debug_out) {
		int i = 0;
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
}

/*
 * Write body of "stackTrace" response for thread `thread_id` to `GE_debug_out`.
 */
static void GE_debug_write_stack_trace_body(uint32_t thread_id)
{
	if (GE_debug_out) {
		GE_context* l_context = GE_main_context;
		GE_call* l_call = l_context->call;
		uint32_t count = 0;
		fprintf(GE_debug_out, "{\"stackFrames\":[");
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
		fprintf(GE_debug_out, "],\"totalFrames\":%d}", count);
	}
}

/*
 * Read two bytes from `file` corresponding to the big endian
 * encoded size of the string, and then read that string and
 * return its value (null terminated).
 * The caller is reponsible for freeing its memory.
 * Return 0 if an error occured when reading from `file`.
 */
static char* GE_debug_get_string(FILE* file)
{
	int b1;
	int b2;
	size_t size = 0;
	size_t count;
	size_t total = 0;
	char* buf;
	b1 = fgetc(GE_debug_in);
	if (b1 == EOF) {
		return 0;
	}
	b2 = fgetc(GE_debug_in);
	if (b2 == EOF) {
		return 0;
	}
	size = ((uint16_t) b1 << 8) | (uint16_t) b2;
	buf = (char*)GE_malloc_atomic(size + 1);
	while (total != size) {
		count = fread(buf, 1, size, GE_debug_in);
		if (count <= 0) {
			GE_free(buf);
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
 */
static void GE_debug_receive()
{
	char* type;
	char* id;
	char* command;
	if (!GE_debug_in || !GE_debug_out) {
		return;
	}
	type = GE_debug_get_string(GE_debug_in);
	if (!type) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocalError\",\"body\":{},\"message\":\"'type' is missing in request\"}\n");
		fflush(GE_debug_out);
		return;
	}
	id = GE_debug_get_string(GE_debug_in);
	if (!id) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocalError\",\"body\":{},\"message\":\"'id' is missing in request\"}\n");
		fflush(GE_debug_out);
		GE_free(type);
		return;
	}
	command = GE_debug_get_string(GE_debug_in);
	if (!command) {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'command' missing in request.\"}\n", id);
		fflush(GE_debug_out);
		GE_free(type);
		GE_free(id);
		return;
	} 
/* TODO */ fprintf(stderr, "command: %s\n", command);
	if(strcmp(command, "initialize") == 0) {
		/* Handle 'initialize'. */
		char* protocol_version;
		protocol_version = GE_debug_get_string(GE_debug_in);
		if (!protocol_version) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'protocolVersion' missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"protocolVersion\":1}}\n", id);
		GE_free(protocol_version);
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
		source_path = GE_debug_get_string(GE_debug_in);
		if (!source_path) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'sourcePath' missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		breakpoints = GE_debug_breakpoints_for_file(source_path);
		GE_free(source_path);
		if (breakpoints) {
			GE_debug_disable_all_file_breakpoints(breakpoints);
		}
		bp_count_str = GE_debug_get_string(GE_debug_in);
		if (sscanf(bp_count_str, "%d", &bp_count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"breakpoint count missing in request '%s'.\"}\n", id, command);
			GE_free(bp_count_str);
			goto GE_debug_receive_done;
		}
		GE_free(bp_count_str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"breakpoints\":[", id);
		for (i = 0; i < bp_count; i++) {
			bp_line_str = GE_debug_get_string(GE_debug_in);
			if (sscanf(bp_line_str, "%d", &bp_line) != 1) {
				GE_free(bp_line_str);
				missing_bp = 1;
				break;
			}
			GE_free(bp_line_str);
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
		fprintf(GE_debug_out, "]}}\n");
		if (missing_bp) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"breakpoint missing in request '%s'.\"}\n", id, command);
		}
	} else if(strcmp(command, "stackTrace") == 0) {
		/* Handle 'stackTrace'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":", id);
		GE_debug_write_stack_trace_body(1);
		fprintf(GE_debug_out, "}\n");
	} else if(strcmp(command, "continue") == 0) {
		/* Handle 'continue'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_debug_continue = 1;
	} else {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"request '%s' not supported.\"}\n", id, command);
	}
GE_debug_receive_done:
	GE_free(type);
	GE_free(id);
	GE_free(command);
	fflush(GE_debug_out);
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

/* Initialize debugging facilities. */
void GE_debug_init()
{
#if defined(_MSC_VER)
    /* Register custom handler. */
    _invalid_parameter_handler oldHandler, newHandler;
    newHandler = my_invalid_parameter_handler;
    oldHandler = _set_invalid_parameter_handler(newHandler);
    /* Disable the default Windows crash dialog box popups (optional but helpful) */
    /* _CrtSetReportMode(_CRT_ASSERT, 0); */

	GE_debug_in = _fdopen(4, "r");
#else
	GE_debug_in = fdopen(4, "r");
#endif
	if (GE_debug_in) {
#if defined(_MSC_VER)
		GE_debug_out = _fdopen(3, "w");
#else
		GE_debug_out = fdopen(3, "w");
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
	if (GE_debug_in && GE_debug_out) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"started\",\"body\":{}}\n");
		fflush(GE_debug_out);
		while (!GE_debug_configuration_done) {
			GE_debug_receive();
		}
	}
}

/* Action executed when breakpoint `breakpoint` is hit. */
void GE_debug_hit_breakpoint(GE_context* ac, GE_debug_breakpoint* breakpoint)
{
	if (!GE_debug_in || !GE_debug_out) {
		return;
	}
	if (breakpoint->enabled) {
		if (ac->call) {
			ac->call->line = breakpoint->last_line;
			ac->call->column = 1;
		}
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"stopped\",\"body\":{\"reason\":\"breakpoint\",\"threadId\":1,\"allThreadsStopped\":true}}\n");
		fflush(GE_debug_out);
		while (!GE_debug_continue) {
			GE_debug_receive();
		}
		GE_debug_continue = 0;
	}	
}

/* Set position of `call`. */
void GE_debug_set_call_position(GE_call* call, uint32_t line, uint32_t column)
{
	call->line = line;
	call->column = column;
}

#ifdef __cplusplus
}
#endif

#endif
#endif
