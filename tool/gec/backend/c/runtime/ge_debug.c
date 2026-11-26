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
#ifndef GE_TYPES_H
#include "ge_types.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <sys/stat.h>
#ifdef GE_WINDOWS
#include <ctype.h> /* For GE_stricmp */
#endif

#if defined(_MSC_VER)
#include <crtdbg.h>  // Required for _set_invalid_parameter_handler
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Maximum value for a thread id, frame id, etc. accepted by ADP. (2^31 -1 ) */
#define GE_DEBUG_MAX_ID 2147483647

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
static long GE_debug_stopped_exception_code = 0;
static const char* GE_debug_stopped_exception_tag = 0;
static uint32_t GE_debug_step_next_thread_id = 0;
static uint32_t GE_debug_step_in_thread_id = 0;
static uint32_t GE_debug_step_out_thread_id = 0;
static uint32_t GE_debug_step_level = 0;

/* Exception breakpoints. */
static int GE_debug_exception_breakpoint_raised = 0;
static int GE_debug_exception_breakpoint_uncaught = 0;
static int GE_debug_exception_breakpoint_unretried = 0;

/* Enabled Exception categories. */
static int GE_debug_exception_breakpoint_categories[] = {
	0,	/* Nothing */
	0,	/* GE_EX_VOID */
	0,	/* GE_EX_MEM */
	0,	/* GE_EX_PRE */
	0,	/* GE_EX_POST */
	0,	/* GE_EX_FLOAT */
	0,	/* GE_EX_CINV */
	0,	/* GE_EX_CHECK */
	0,	/* GE_EX_FAIL */
	0,	/* GE_EX_WHEN */
	0,	/* GE_EX_VAR */
	0,	/* GE_EX_LINV */
	0,	/* GE_EX_SIG */
	0,	/* GE_EX_BYE */
	0,	/* GE_EX_RESC */
	0,	/* GE_EX_OMEM */
	0,	/* GE_EX_RES */
	0,	/* GE_EX_CDEF */
	0,	/* GE_EX_EXT */
	0,	/* GE_EX_VEXP */
	0,	/* GE_EX_HDLR */
	0,	/* GE_EX_IO */
	0,	/* GE_EX_SYS */
	0,	/* GE_EX_RETR */
	0,	/* GE_EX_PROG */
	0,	/* GE_EX_FATAL */
	0,	/* GE_EX_DOL */
	0,	/* GE_EX_ISE_IO */
	0,	/* GE_EX_COM */
	0,	/* GE_EX_RT_CHECK */
	0,	/* GE_EX_OLD */
	0,	/* GE_EX_SEL */
	0,	/* GE_EX_DIRTY */
	0	/* GE_EX_REGION_ID */
};

/* Used to generate debugger thread ids. */
static uint32_t GE_debug_thread_counter = 0;

/* Eiffel execution threads. */
static GE_context* GE_debug_first_thread = 0;
static GE_context* GE_debug_last_thread = 0;

/*
 * Set 'debug_status_pending' in all threads except `a_thread` (if not NULL)
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread other than `a_thread` (or of all threads if `a_thread` is NULL).
 */
static void GE_unprotected_debug_set_status_pending(GE_context* a_thread)
{
	if (!GE_debug_out) {
		return;
	}
	GE_context* l_other_thread = GE_debug_first_thread;
	while (l_other_thread) {
		if (l_other_thread != a_thread) {
			GE_mutex_lock((EIF_POINTER)l_other_thread->debug_mutex);
			l_other_thread->debug_status_pending = 1;
			GE_mutex_unlock((EIF_POINTER)l_other_thread->debug_mutex);
		}
		l_other_thread = l_other_thread->next_thread;
	}
}

/*
 * Write escaped version of `s` to `GE_debug_out`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_debug_write_escaped_string(const char* s)
{
	int i = 0;
	char c;

	if (!GE_debug_out) {
		return;
	}
	while (s[i]) {
		c = s[i];
		switch (c) {
		case '\\':
			fputc('\\', GE_debug_out);
			fputc('\\', GE_debug_out);
			break;
		case '\"':
			fputc('\\', GE_debug_out);
			fputc('\"', GE_debug_out);
			break;
		case '\n':
			fputc('\\', GE_debug_out);
			fputc('n', GE_debug_out);
			break;
		case '\r':
			fputc('\\', GE_debug_out);
			fputc('r', GE_debug_out);
			break;
		case '\t':
			fputc('\\', GE_debug_out);
			fputc('t', GE_debug_out);
			break;
		default:
			if ((unsigned char)c <= 0x1F) {
				fprintf(GE_debug_out, "\\u%04X", c);
			} else {
				fputc(c, GE_debug_out);
			}
		}
		i++;
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
		GE_unprotected_debug_set_status_pending(a_thread);
		GE_debug_is_stopping = 0;
		GE_debug_is_stopped = 1;
		if (!GE_debug_stopped_thread_id && GE_debug_first_thread) {
			GE_debug_stopped_thread_id = GE_debug_first_thread->debug_thread_id;
		}
		if (!GE_debug_stopped_reason) {
			GE_debug_stopped_reason = "pause";
		}
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"stopped\",\"body\":{\"reason\":\"%s\",\"threadId\":%u,\"allThreadsStopped\":true", GE_debug_stopped_reason, GE_debug_stopped_thread_id);
		if (strcmp(GE_debug_stopped_reason, "exception") == 0) {
			fprintf(GE_debug_out, ",\"text\":\"");
			if (GE_debug_stopped_exception_tag && GE_debug_stopped_exception_tag[0] != '\0') {
				GE_debug_write_escaped_string(GE_debug_stopped_exception_tag);
				fprintf(GE_debug_out, ": ");
			}
			GE_debug_write_escaped_string(GE_exception_tag(GE_debug_stopped_exception_code));
			fprintf(GE_debug_out, "\"");
		}
		fprintf(GE_debug_out, "}}\n");
		fflush(GE_debug_out);
	}
	return l_all_stopped;
}

/*
 * Eiffel thread with a given debugger thread id.
 * Null if not found.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static GE_context* GE_unprotected_debug_thread_with_id(uint32_t a_id)
{
	GE_context* l_thread;

	l_thread = GE_debug_first_thread;
	while (l_thread) {
		if (l_thread->debug_thread_id == a_id) {
			return l_thread;
		}
		l_thread = l_thread->next_thread;
	}
	return 0;
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
	if (GE_debug_thread_counter < GE_DEBUG_MAX_ID) {
		GE_debug_thread_counter++;
		a_thread->debug_thread_id = GE_debug_thread_counter;
	} else {
		if (GE_debug_thread_counter <= GE_DEBUG_MAX_ID) {
			GE_debug_thread_counter++;
		}
		a_thread->debug_thread_id = 0;
	}
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
 * - Mutex of `a_thread`.
 */
void GE_debug_remove_thread(GE_context* a_thread)
{
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	while (GE_debug_is_stopped || GE_debug_is_stopping) {
		GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
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
		while (a_thread->is_stopped) {
			GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
		}
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	}
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

#ifdef GE_WINDOWS
/* Compare strings in a case-insensitive way for ASCII characters (<= 127). */
static int GE_stricmp(const char *s1, const char *s2)
{
	int c1, c2;

	do {
		c1 = (unsigned char) *s1++;
		c2 = (unsigned char) *s2++;

		if (c1 <= 127 && c2 <= 127) {
			c1 = tolower(c1);
			c2 = tolower(c2);
		}

		if (c1 != c2) {
			return c1 - c2;
		}
	} while (c1 != 0);
	return 0;
}
#endif

/*
 * Breakpoints for file `filename` if any, NULL otherwise.
 * 
 * Thread-safe.
 */
static GE_debug_file_breakpoints* GE_debug_breakpoints_for_file(char* filename)
{
	uint32_t i;
	for (i = 0; i < GE_debug_breakpoint_count; i++) {
#ifdef GE_WINDOWS
		if (GE_stricmp(GE_debug_breakpoints[i]->filename, filename) == 0) {
#else
		if (strcmp(GE_debug_breakpoints[i]->filename, filename) == 0) {
#endif
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
	GE_unprotected_debug_set_status_pending(NULL);
	nb = breakpoints->breakpoint_count;
	for (i = 0; i < nb; i++) {
		breakpoints->breakpoints[i]->enabled = 0;
	}
}

/*
 * Disable all exception breakpoints.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_disable_all_exception_breakpoints()
{
	GE_unprotected_debug_set_status_pending(NULL);
	GE_debug_exception_breakpoint_raised = 0;
	GE_debug_exception_breakpoint_uncaught = 0;
	GE_debug_exception_breakpoint_unretried = 0;
}

/*
 * Disable all exception categories.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_disable_all_exception_categories()
{
	int i;
	GE_unprotected_debug_set_status_pending(NULL);
	for (i = 1; i <= GE_EX_NEX; i++) {
		GE_debug_exception_breakpoint_categories[i] = 0;
	}
}

/*
 * Enable exception category `category_id`.
 * Return 0 if this category is unknown.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static int GE_unprotected_debug_enable_exception_category(char* category_id)
{
	GE_unprotected_debug_set_status_pending(NULL);
	if (strcmp(category_id, "precondition") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_PRE] = 1;
	} else if (strcmp(category_id, "postcondition") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_POST] = 1;
	} else if (strcmp(category_id, "invariant") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_CINV] = 1;
	} else if (strcmp(category_id, "check") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_CHECK] = 1;
	} else if (strcmp(category_id, "loop_invariant") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_LINV] = 1;
	} else if (strcmp(category_id, "loop_variant") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_VAR] = 1;
	} else if (strcmp(category_id, "developer_exception") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_PROG] = 1;
	} else if (strcmp(category_id, "void_target") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_VOID] = 1;
	} else if (strcmp(category_id, "routine_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_FAIL] = 1;
	} else if (strcmp(category_id, "inspect_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_WHEN] = 1;
	} else if (strcmp(category_id, "deferred_creation_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_CDEF] = 1;
	} else if (strcmp(category_id, "void_expanded_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_VEXP] = 1;
	} else if (strcmp(category_id, "old_expression_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_OLD] = 1;
	} else if (strcmp(category_id, "cecil_melted_code_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_DOL] = 1;
	} else if (strcmp(category_id, "floating_point_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_FLOAT] = 1;
	} else if (strcmp(category_id, "scoop_processor_dirty") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_DIRTY] = 1;
	} else if (strcmp(category_id, "scoop_region_id_overflow") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_REGION_ID] = 1;
	} else if (strcmp(category_id, "retrieval_error") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_RETR] = 1;
	} else if (strcmp(category_id, "serialization_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_SEL] = 1;
	} else if (strcmp(category_id, "io_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_IO] = 1;
	} else if (strcmp(category_id, "com_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_COM] = 1;
	} else if (strcmp(category_id, "no_more_memory") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_MEM] = 1;
	} else if (strcmp(category_id, "out_of_memory") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_OMEM] = 1;
	} else if (strcmp(category_id, "operating_system_signal") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_SIG] = 1;
	} else if (strcmp(category_id, "operating_system_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_SYS] = 1;
	} else if (strcmp(category_id, "signal_handler_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_HDLR] = 1;
	} else if (strcmp(category_id, "eiffel_runtime_io_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_ISE_IO] = 1;
	} else if (strcmp(category_id, "eiffel_runtime_fatal_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_FATAL] = 1;
	} else if (strcmp(category_id, "eiffel_runtime_panic") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_BYE] = 1;
	} else if (strcmp(category_id, "eiffel_runtime_check_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_RT_CHECK] = 1;
	} else if (strcmp(category_id, "exception_in_rescue_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_RESC] = 1;
	} else if (strcmp(category_id, "resumption_attempt_failure") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_RES] = 1;
	} else if (strcmp(category_id, "external_event") == 0) {
		GE_debug_exception_breakpoint_categories[GE_EX_EXT] = 1;
	} else {
		return 0;
	}
	return 1;
}

/*
 * Pause all Eiffel threads.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_pause_all()
{
	if (!GE_debug_is_stopping && !GE_debug_is_stopped) {
		GE_unprotected_debug_set_status_pending(NULL);
		GE_debug_is_stopping = 1;
		GE_debug_step_next_thread_id = 0;
		GE_debug_step_in_thread_id = 0;
		GE_debug_step_out_thread_id = 0;
		GE_debug_step_level = 0;
		GE_unprotected_debug_check_and_send_all_stopped(NULL);
	}
}

/*
 * Continue execution of all Eiffel threads.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread.
 */
static void GE_unprotected_debug_continue_all()
{
	GE_context* l_thread;

	GE_unprotected_debug_set_status_pending(NULL);
	GE_debug_is_stopping = 0;
	GE_debug_is_stopped = 0;
	GE_debug_stopped_thread_id = 0;
	GE_debug_stopped_reason = 0;
	GE_debug_stopped_exception_code = 0;
	GE_debug_stopped_exception_tag = 0;
	GE_debug_step_next_thread_id = 0;
	GE_debug_step_in_thread_id = 0;
	GE_debug_step_out_thread_id = 0;
	GE_debug_step_level = 0;
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		l_thread->is_stopped = 0;
		GE_condition_variable_broadcast((EIF_POINTER)l_thread->debug_condition_variable);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		l_thread = l_thread->next_thread;
	}
}

/*
 * Continue execution of all Eiffel threads.
 * Move one step over the same frame in thread `thread_id`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread.
 */
static void GE_unprotected_debug_step_next(uint32_t thread_id)
{
	GE_context* l_thread;
	GE_call* l_call;
	uint32_t count = 0;

	GE_unprotected_debug_set_status_pending(NULL);
	GE_debug_is_stopping = 0;
	GE_debug_is_stopped = 0;
	GE_debug_stopped_thread_id = 0;
	GE_debug_stopped_reason = 0;
	GE_debug_stopped_exception_code = 0;
	GE_debug_stopped_exception_tag = 0;
	GE_debug_step_next_thread_id = thread_id;
	GE_debug_step_in_thread_id = 0;
	GE_debug_step_out_thread_id = 0;
	GE_debug_step_level = 0;
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		if (l_thread->debug_thread_id == thread_id) {
			GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
			l_call = l_thread->call;
			while (l_call && count < GE_DEBUG_MAX_ID) {
				count++;
				l_call = l_call->caller;
			}
			GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
			GE_debug_step_level = count;
			break;
		}
		l_thread = l_thread->next_thread;
	}
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		l_thread->is_stopped = 0;
		GE_condition_variable_broadcast((EIF_POINTER)l_thread->debug_condition_variable);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		l_thread = l_thread->next_thread;
	}
}

/*
 * Continue execution of all Eiffel threads.
 * Step into the next frame in thread `thread_id`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread.
 */
static void GE_unprotected_debug_step_in(uint32_t thread_id)
{
	GE_context* l_thread;
	GE_call* l_call;
	uint32_t count = 0;

	GE_unprotected_debug_set_status_pending(NULL);
	GE_debug_is_stopping = 0;
	GE_debug_is_stopped = 0;
	GE_debug_stopped_thread_id = 0;
	GE_debug_stopped_reason = 0;
	GE_debug_stopped_exception_code = 0;
	GE_debug_stopped_exception_tag = 0;
	GE_debug_step_next_thread_id = 0;
	GE_debug_step_in_thread_id = thread_id;
	GE_debug_step_out_thread_id = 0;
	GE_debug_step_level = 0;
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		if (l_thread->debug_thread_id == thread_id) {
			GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
			l_call = l_thread->call;
			while (l_call && count < GE_DEBUG_MAX_ID) {
				count++;
				l_call = l_call->caller;
			}
			GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
			GE_debug_step_level = count;
			break;
		}
		l_thread = l_thread->next_thread;
	}
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		l_thread->is_stopped = 0;
		GE_condition_variable_broadcast((EIF_POINTER)l_thread->debug_condition_variable);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		l_thread = l_thread->next_thread;
	}
}

/*
 * Continue execution of all Eiffel threads.
 * Step out of the current frame in thread `thread_id`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of each thread.
 */
static void GE_unprotected_debug_step_out(uint32_t thread_id)
{
	GE_context* l_thread;
	GE_call* l_call;
	uint32_t count = 0;

	GE_unprotected_debug_set_status_pending(NULL);
	GE_debug_is_stopping = 0;
	GE_debug_is_stopped = 0;
	GE_debug_stopped_thread_id = 0;
	GE_debug_stopped_reason = 0;
	GE_debug_stopped_exception_code = 0;
	GE_debug_stopped_exception_tag = 0;
	GE_debug_step_next_thread_id = 0;
	GE_debug_step_in_thread_id = 0;
	GE_debug_step_out_thread_id = thread_id;
	GE_debug_step_level = 0;
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		if (l_thread->debug_thread_id == thread_id) {
			GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
			l_call = l_thread->call;
			while (l_call && count < GE_DEBUG_MAX_ID) {
				count++;
				l_call = l_call->caller;
			}
			GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
			GE_debug_step_level = count;
			break;
		}
		l_thread = l_thread->next_thread;
	}
	l_thread = GE_debug_first_thread;
	while (l_thread) {
		GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
		l_thread->is_stopped = 0;
		GE_condition_variable_broadcast((EIF_POINTER)l_thread->debug_condition_variable);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		l_thread = l_thread->next_thread;
	}
}

/* Is `c` a printable unicode character? */
static int GE_debug_is_printable_cp(uint32_t c)
{
    if (c > 0x10FFFF)                  return 0;  // beyond Unicode
    if (c < 0x20 || (c >= 0x7F && c <= 0x9F)) return 0;  // Cc controls
    if (c >= 0xD800 && c <= 0xDFFF)    return 0;  // surrogates
    if (c >= 0xE000 && c <= 0xF8FF)    return 0;  // private use (BMP)
    if (c >= 0xF0000)                  return 0;  // private use planes 15-16
    if (c >= 0xFDD0 && c <= 0xFDEF)    return 0;  // noncharacters
    if ((c & 0xFFFE) == 0xFFFE)        return 0;  // U+xFFFE / U+xFFFF

    // Optional: invisible format characters (Cf) and line/paragraph separators
    if (c == 0x00AD || c == 0x061C || c == 0x180E || c == 0xFEFF) return 0;
    if (c >= 0x200B && c <= 0x200F)    return 0;  // zero-width, LRM, RLM
    if (c >= 0x2028 && c <= 0x202E)    return 0;  // separators, bidi embeds
    if (c >= 0x2060 && c <= 0x206F)    return 0;  // word joiner, etc.
    if (c >= 0xFFF9 && c <= 0xFFFB)    return 0;  // interlinear annotation
    return 1;
}

/*
 * Write printable version of `c` to `GE_debug_out`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_debug_write_printable_character(const uint32_t c)
{
	if (c > 0xFFFF || (c > 127 && !GE_debug_is_printable_cp(c))) {
		fprintf(GE_debug_out, "%%/%u/", c);
	} else if (c > 127) {
		fprintf(GE_debug_out, "\\u%04X", c);
	} else switch (c) {
		case ' ':
		case '!':
		case '#':
		case '$':
		case '&':
			fputc((char)c, GE_debug_out);
			break;
		case '\b':
			fprintf(GE_debug_out, "%%B");
			break;
		case '\f':
			fprintf(GE_debug_out, "%%F");
			break;
		case '\n':
			fprintf(GE_debug_out, "%%N");
			break;
		case '\r':
			fprintf(GE_debug_out, "%%R");
			break;
		case '\t':
			fprintf(GE_debug_out, "%%T");
			break;
		case '\0':
			fprintf(GE_debug_out, "%%U");
			break;
		case '%':
			fprintf(GE_debug_out, "%%%%");
			break;
		case '\'':
			fprintf(GE_debug_out, "%%'");
			break;
		case '\"':
			fprintf(GE_debug_out, "%%\\\"");
			break;
		case '\\':
			fprintf(GE_debug_out, "\\\\");
			break;
		default:
			if (c >= '(' && c <= '~') {
				fputc((char)c, GE_debug_out);
			} else {
				fprintf(GE_debug_out, "%%/%u/", c);
			}
	}
}

/*
 * Write `a_variable` to `GE_debug_out`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_write_variable(GE_debug_variable* a_variable)
{
	uint32_t attribute_count;
	uint32_t item_count = 0;

	fprintf(GE_debug_out, "{\"name\":\"%s\",\"value\":", a_variable->name);
	EIF_TYPE_INDEX l_type_id = a_variable->type_id;
	if (l_type_id == 0 || !(GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_EXPANDED)) {
		EIF_REFERENCE l_value = *(EIF_REFERENCE*)a_variable->address;
		if (l_value) {
			EIF_TYPE_INDEX l_object_type_id = l_value->id;
			if (!(GE_type_infos[l_object_type_id].flags & GE_TYPE_FLAG_EXPANDED)) {
				/* Not a boxed expanded object. */
				l_type_id = l_object_type_id;
			}
			char* l_type_name = (char*)GE_type_infos[l_object_type_id].name;
			if (l_type_name[0] == '!') l_type_name++;
			fprintf(GE_debug_out, "\"<0x%" EIF_POINTER_DISPLAY ">\",\"type\":\"%s\",\"variablesReference\":", (uintptr_t)l_value, l_type_name);
			attribute_count = GE_type_infos[l_object_type_id].attribute_count;
			if (GE_type_infos[l_value->id].flags & GE_TYPE_FLAG_SPECIAL) {
				item_count = *(EIF_INTEGER*)((char*)l_value + GE_type_infos[l_value->id].attributes[1]->offset);
				attribute_count--;
			}
			if (attribute_count > 0 || item_count > 0) {
				fprintf(GE_debug_out, "{\"kind\":\"attributes\",\"id\":\"0x%016" EIF_POINTER_DISPLAY "\",\"typeId\":%d}", (uintptr_t)l_value, l_type_id);
				if (attribute_count > 0) {
					fprintf(GE_debug_out, ",\"namedVariables\":%u", attribute_count);
				}
				if (item_count > 0) {
					fprintf(GE_debug_out, ",\"indexedVariables\":%u", item_count);
				}
				fputc('}', GE_debug_out);
			} else {
				fprintf(GE_debug_out, "0}");
			}
		} else if (l_type_id != 0) {
			char* l_type_name = (char*)GE_type_infos[l_type_id].name;
			if (l_type_name[0] == '!') l_type_name++;
			fprintf(GE_debug_out, "\"Void\",\"type\":\"%s\",\"variablesReference\":0}", l_type_name);
		} else {
			fprintf(GE_debug_out, "\"Void\",\"variablesReference\":0}");
		}
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_BOOLEAN) {
		EIF_BOOLEAN l_value = *(EIF_BOOLEAN*)a_variable->address;
		fprintf(GE_debug_out, "\"%s\",\"type\":\"BOOLEAN\",\"variablesReference\":0}", EIF_TEST(l_value)?"True": "False");
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_CHARACTER_8) {
		EIF_CHARACTER_8 l_value = *(EIF_CHARACTER_8*)a_variable->address;
		fprintf(GE_debug_out, "\"%u '", (uint32_t)l_value);
		GE_debug_write_printable_character(l_value);
		fprintf(GE_debug_out, "'\",\"type\":\"CHARACTER_8\",\"variablesReference\":0}");
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_CHARACTER_32) {
		EIF_CHARACTER_32 l_value = *(EIF_CHARACTER_32*)a_variable->address;
		fprintf(GE_debug_out, "\"%u '", (uint32_t)l_value);
		GE_debug_write_printable_character(l_value);
		fprintf(GE_debug_out, "'\",\"type\":\"CHARACTER_32\",\"variablesReference\":0}");
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_8) {
		EIF_INTEGER_8 l_value = *(EIF_INTEGER_8*)a_variable->address;
		fprintf(GE_debug_out, "\"%d\",\"type\":\"INTEGER_8\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_16) {
		EIF_INTEGER_16 l_value = *(EIF_INTEGER_16*)a_variable->address;
		fprintf(GE_debug_out, "\"%d\",\"type\":\"INTEGER_16\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_32) {
		EIF_INTEGER_32 l_value = *(EIF_INTEGER_32*)a_variable->address;
		fprintf(GE_debug_out, "\"%d\",\"type\":\"INTEGER_32\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_64) {
		EIF_INTEGER_64 l_value = *(EIF_INTEGER_64*)a_variable->address;
		fprintf(GE_debug_out, "\"%" PRId64 "\",\"type\":\"INTEGER_64\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_8) {
		EIF_NATURAL_8 l_value = *(EIF_NATURAL_8*)a_variable->address;
		fprintf(GE_debug_out, "\"%u\",\"type\":\"NATURAL_8\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_16) {
		EIF_NATURAL_16 l_value = *(EIF_NATURAL_16*)a_variable->address;
		fprintf(GE_debug_out, "\"%u\",\"type\":\"NATURAL_16\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_32) {
		EIF_NATURAL_32 l_value = *(EIF_NATURAL_32*)a_variable->address;
		fprintf(GE_debug_out, "\"%u\",\"type\":\"NATURAL_32\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_64) {
		EIF_NATURAL_64 l_value = *(EIF_NATURAL_64*)a_variable->address;
		fprintf(GE_debug_out, "\"%" PRIu64 "\",\"type\":\"NATURAL_64\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_REAL_32) {
		EIF_REAL_32 l_value = *(EIF_REAL_32*)a_variable->address;
		fprintf(GE_debug_out, "\"%g\",\"type\":\"REAL_32\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_REAL_64) {
		EIF_REAL_64 l_value = *(EIF_REAL_64*)a_variable->address;
		fprintf(GE_debug_out, "\"%.17g\",\"type\":\"REAL_64\",\"variablesReference\":0}", l_value);
	} else if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_POINTER) {
		EIF_POINTER l_value = *(EIF_POINTER*)a_variable->address;
		fprintf(GE_debug_out, "\"<0x%" EIF_POINTER_DISPLAY ">\",\"type\":\"POINTER\",\"variablesReference\":0}", (uintptr_t)l_value);
	} else {
		/* User-defined expanded attribute type. */
		void* l_value = (void*)a_variable->address;
		char* l_type_name = (char*)GE_type_infos[l_type_id].name;
		if (l_type_name[0] == '!') l_type_name++;
		fprintf(GE_debug_out, "\"<0x%" EIF_POINTER_DISPLAY ">\",\"type\":\"%s\",\"variablesReference\":", (uintptr_t)l_value, l_type_name);
		if (GE_type_infos[l_type_id].attribute_count > 0) {
			fprintf(GE_debug_out, "{\"kind\":\"attributes\",\"id\":\"0x%016" EIF_POINTER_DISPLAY "\",\"typeId\":%d},\"namedVariables\":%u}", (uintptr_t)l_value, l_type_id, GE_type_infos[l_type_id].attribute_count);
		} else {
			fprintf(GE_debug_out, "0}");
		}
	}
}

/*
 * Write body of "threads" response to `GE_debug_out`.
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_write_threads_body()
{
	GE_context* l_thread;
	uint32_t l_thread_id;
	uint32_t count = 0;

	if (!GE_debug_out) {
		return;
	}
	if (GE_debug_thread_counter > GE_DEBUG_MAX_ID) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Too many threads (>2^31-1).\"");
	} else {
		fprintf(GE_debug_out, "\"success\":true,\"body\":{\"threads\":[");
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
				fprintf(GE_debug_out, "{\"id\":%u,\"name\":\"SCOOP processor %u\"}", l_thread_id, l_thread_id - 1);
#else
				fprintf(GE_debug_out, "{\"id\":%u,\"name\":\"Thread %u\"}", l_thread_id, l_thread_id - 1);
#endif
			}
			l_thread = l_thread->next_thread;
		}
		fprintf(GE_debug_out, "]}");
	}
}

/*
 * Write body of "stackTrace" response for thread `thread_id` to `GE_debug_out`.
 * `start_frame` is the first frame to include in the response (counting from 1).
 * `levels` is the number of frames to include in the response (0 means all frames
 * after `start_frame`). The response may include less frames if there are less
 * actual frames than requested.
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of the thread `thread_id`.
 */
static void GE_unprotected_debug_write_stack_trace_body(uint32_t thread_id, uint32_t start_frame, uint32_t levels)
{
	GE_context* l_thread;
	uint32_t count = 0;
	uint32_t levels_count = 0;
	int levels_reached = 0;

	if (!GE_debug_out) {
		return;
	}
	l_thread = GE_unprotected_debug_thread_with_id(thread_id);
	if (!l_thread) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"No thread found with id %u.\"", thread_id);
		return;
	}
	GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
	if (!l_thread->is_stopped && !l_thread->is_blocking) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Thread %u is not stopped.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	GE_call* l_call = l_thread->call;
	while (l_call && count <= GE_DEBUG_MAX_ID) {
		count++;
		l_call = l_call->caller;
	}
	if (count > GE_DEBUG_MAX_ID) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Too many stack frames in thread %u (>2^31-1).\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	} 
	fprintf(GE_debug_out, "\"success\":true,\"body\":{\"stackFrames\":[");
	l_call = l_thread->call;
	count = 0;
	while (l_call) {
		count++;
		if (count < start_frame) {
			l_call = l_call->caller;
			continue;
		}
		if (levels_reached) {
			l_call = l_call->caller;
			continue;
		}
		levels_count++;
		if (levels != 0 && levels_count >= levels) {
			levels_reached = 1;
		}
		if (count != start_frame) {
			fputc(',', GE_debug_out);
		}
		fprintf(GE_debug_out, "{\"id\":{\"threadId\":%u,\"frameId\":\"0x%016" EIF_POINTER_DISPLAY "\"},\"name\":\"", thread_id, (uintptr_t)l_call);
		GE_debug_write_escaped_string(l_call->feature_name);
		fprintf(GE_debug_out, "\",\"line\":%u,\"column\":%u", l_call->line, l_call->column);
		if (!l_call->caller || strcmp(l_call->feature_name, "GC dispose") == 0 || strcmp(l_call->feature_name, "SCOOP initialization") == 0) {
			fprintf(GE_debug_out, ",\"presentationHint\":\"label\"");
		} else {
			fprintf(GE_debug_out, ",\"source\":{\"name\":\"");
			GE_debug_write_escaped_string(l_call->class_name);
			fprintf(GE_debug_out, "\",\"path\":\"");
			GE_debug_write_escaped_string(l_call->filename);
			fprintf(GE_debug_out, "\"}");
		}
		fputc('}', GE_debug_out);
		l_call = l_call->caller;
	}
	fprintf(GE_debug_out, "],\"totalFrames\":%u}", count);
	GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
}

/*
 * Write body of "scopes" response for `a_frame` to `GE_debug_out`.
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 * Protected by:
 * - Mutex of the thread `thread_id`.
 */
static void GE_unprotected_debug_write_scopes_body(uint32_t thread_id, GE_call* a_frame)
{
	uint32_t nb = 0;
	GE_context* l_thread;

	if (!GE_debug_out) {
		return;
	}
	l_thread = GE_unprotected_debug_thread_with_id(thread_id);
	if (!l_thread) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"No thread found with id %u.\"", thread_id);
		return;
	}
	GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
	if (!l_thread->is_stopped && !l_thread->is_blocking) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Thread %u is not stopped.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	GE_call* l_call = l_thread->call;
	while (l_call && l_call != a_frame) {
		l_call = l_call->caller;
	}
	if (l_call != a_frame) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"stack frame not found in thread %u.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	fprintf(GE_debug_out, "\"success\":true,\"body\":{\"scopes\":[");
	if (a_frame->argument_count > 0) {
		fprintf(GE_debug_out, "{\"name\":\"Arguments\",\"presentationHint\":\"arguments\",\"variablesReference\":{\"kind\":\"arguments\",\"id\":\"0x%016" EIF_POINTER_DISPLAY "\",\"threadId\":%u},\"namedVariables\":%u}", (uintptr_t)a_frame, thread_id, a_frame->argument_count);
		nb++;
	}
	if (a_frame->local_count > 0) {
		if (nb > 0) {
			fputc(',', GE_debug_out);
		}
		fprintf(GE_debug_out, "{\"name\":\"Locals\",\"presentationHint\":\"locals\",\"variablesReference\":{\"kind\":\"locals\",\"id\":\"0x%016" EIF_POINTER_DISPLAY "\",\"threadId\":%u},\"namedVariables\":%u}", (uintptr_t)a_frame, thread_id, a_frame->local_count);
		nb++;
	}
	fprintf(GE_debug_out, "]}");
	GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex); 
}

/*
 * Write body of "argumentVariables" response for `a_frame` to `GE_debug_out`.
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_write_argument_variables_body(uint32_t thread_id, GE_call* a_frame, char* filter, uint32_t start, uint32_t count)
{
	GE_context* l_thread;
	uint32_t argument_count = 0;
	uint32_t i;
	uint32_t nb = 0;

	if (!GE_debug_out) {
		return;
	}
	l_thread = GE_unprotected_debug_thread_with_id(thread_id);
	if (!l_thread) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"No thread found with id %u.\"", thread_id);
		return;
	}
	GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
	if (!l_thread->is_stopped && !l_thread->is_blocking) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Thread %u is not stopped.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	GE_call* l_call = l_thread->call;
	while (l_call && l_call != a_frame) {
		l_call = l_call->caller;
	}
	if (l_call != a_frame) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"stack frame not found in thread %u.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	argument_count = a_frame->argument_count;
	fprintf(GE_debug_out, "\"success\":true,\"body\":{\"variables\":[");
	if(strcmp(filter, "named") == 0 || strcmp(filter, "all") == 0) {
		for (i = start; i < argument_count; i++) {
			if (i > start) {
				fputc(',', GE_debug_out);
			}
			GE_unprotected_debug_write_variable(a_frame->arguments[i]);
			nb++;
			if (count > 0 && nb >= count) {
				break;
			}
		}
	}
	fprintf(GE_debug_out, "]}");
	GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex); 
}

/*
 * Write body of "localVariables" response for `a_frame` to `GE_debug_out`.
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_write_local_variables_body(uint32_t thread_id, GE_call* a_frame, char* filter, uint32_t start, uint32_t count)
{
	GE_context* l_thread;
	uint32_t local_count = 0;
	uint32_t i;
	uint32_t nb = 0;

	if (!GE_debug_out) {
		return;
	}
	l_thread = GE_unprotected_debug_thread_with_id(thread_id);
	if (!l_thread) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"No thread found with id %u.\"", thread_id);
		return;
	}
	GE_mutex_lock((EIF_POINTER)l_thread->debug_mutex);
	if (!l_thread->is_stopped && !l_thread->is_blocking) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"Thread %u is not stopped.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	GE_call* l_call = l_thread->call;
	while (l_call && l_call != a_frame) {
		l_call = l_call->caller;
	}
	if (l_call != a_frame) {
		fprintf(GE_debug_out, "\"success\":false,\"body\":{},\"message\":\"stack frame not found in thread %u.\"", thread_id);
		GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex);
		return;
	}
	local_count = a_frame->local_count;
	fprintf(GE_debug_out, "\"success\":true,\"body\":{\"variables\":[");
	if(strcmp(filter, "named") == 0 || strcmp(filter, "all") == 0) {
		for (i = start; i < local_count; i++) {
			if (i > start) {
				fputc(',', GE_debug_out);
			}
			GE_unprotected_debug_write_variable(a_frame->locals[i]);
			nb++;
			if (count > 0 && nb >= count) {
				break;
			}
		}
	}
	fprintf(GE_debug_out, "]}");
	GE_mutex_unlock((EIF_POINTER)l_thread->debug_mutex); 
}

/*
 * Write body of "attributeVariables" response for `a_frame` to `GE_debug_out`.
 *
 * Not thread-safe.
 * Need to be protected by:
 * - `GE_debug_mutex`.
 */
static void GE_unprotected_debug_write_attribute_variables_body(void* object, EIF_TYPE_INDEX type_id, char* filter, uint32_t start, uint32_t count)
{
	uint32_t i;
	uint32_t nb = 0;
	uint32_t l_physical_offset = 0;

	if (!GE_debug_out) {
		return;
	}
	fprintf(GE_debug_out, "\"success\":true,\"body\":{\"variables\":[");
	if (object) {
		EIF_TYPE_INDEX l_type_id = type_id;
		if (!(GE_type_infos[type_id].flags & GE_TYPE_FLAG_EXPANDED)) {
			l_type_id = ((EIF_REFERENCE)object)->id;
			if ((GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_EXPANDED) && !(GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_BASIC_MASK)) {
				/* This is a boxed user-defined expanded object. */
				l_physical_offset = GE_type_infos[l_type_id].attributes[GE_type_infos[l_type_id].attribute_count]->offset;
			}
		}
		uint32_t attribute_count = 0;
		if(strcmp(filter, "named") == 0 || strcmp(filter, "all") == 0) {
			attribute_count = GE_type_infos[l_type_id].attribute_count;
			if (GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_SPECIAL) {
				attribute_count--;
			}
			for (i = start; i < attribute_count; i++) {
				GE_attribute* l_attribute = GE_type_infos[l_type_id].attributes[i];
				GE_debug_variable l_variable = {(char*)l_attribute->name, GE_decoded_type(l_attribute->type_id).id, (void*)GE_field_address_at(l_attribute->offset, object, l_physical_offset)};
				if (nb > 0) {
					fputc(',', GE_debug_out);
				}
				GE_unprotected_debug_write_variable(&l_variable);
				nb++;
				if (count > 0 && nb >= count) {
					break;
				}
			}
		}
		if((strcmp(filter, "indexed") == 0 || strcmp(filter, "all")  == 0) && (count == 0 || nb < count)) {
			if (GE_type_infos[l_type_id].flags & GE_TYPE_FLAG_SPECIAL) {
				EIF_INTEGER item_count = *(EIF_INTEGER*)((char*)object + GE_type_infos[l_type_id].attributes[1]->offset);
				GE_attribute* l_item_attribute = GE_type_infos[l_type_id].attributes[GE_type_infos[l_type_id].attribute_count - 1];
				uint32_t volatile l_item_offset = l_item_attribute->offset;
				EIF_TYPE_INDEX l_item_type_id = GE_decoded_type(l_item_attribute->type_id).id;
				uint16_t volatile l_item_flags = GE_type_infos[l_item_type_id].flags;
				uint32_t item_start = (start < attribute_count ? 0 : start - attribute_count);
				for (i = item_start; i < item_count; i++) {
					GE_debug_variable l_variable;
					char l_item_name[100];
					sprintf(l_item_name, "item %u", i);
					if (!(l_item_flags & GE_TYPE_FLAG_EXPANDED)) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_REFERENCE*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_BOOLEAN) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_BOOLEAN*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_CHARACTER_8) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_CHARACTER_8*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_CHARACTER_32) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_CHARACTER_32*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_8) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_INTEGER_8*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_16) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_INTEGER_16*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_32) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_INTEGER_32*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_INTEGER_64) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_INTEGER_64*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_8) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_NATURAL_8*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_16) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_NATURAL_16*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_32) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_NATURAL_32*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_NATURAL_64) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_NATURAL_64*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_REAL_32) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_REAL_32*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_REAL_64) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_REAL_64*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else if ((l_item_flags & GE_TYPE_FLAG_BASIC_MASK) == GE_TYPE_FLAG_POINTER) {
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)((EIF_POINTER*)GE_field_address_at(l_item_offset, object, l_physical_offset) + i)};
						l_variable = l_temp_variable;
					} else {
						/* User-defined expanded item type. */
						uint32_t l_item_size = l_item_attribute->size;
						GE_debug_variable l_temp_variable = {l_item_name, l_item_type_id, (void*)GE_field_address_at(l_item_offset + i * l_item_size, object, l_physical_offset)};
						l_variable = l_temp_variable;
					}
					if (nb > 0) {
						fputc(',', GE_debug_out);
					}
					GE_unprotected_debug_write_variable(&l_variable);
					nb++;
					if (count > 0 && nb >= count) {
						break;
					}
				}
			}
		}
	}
	fprintf(GE_debug_out, "]}");
}

typedef enum {
	GE_DEBUG_READ_OK,
	GE_DEBUG_READ_EOF,
	GE_DEBUG_READ_ERROR,
	GE_DEBUG_READ_MEMORY_ERROR
} GE_debug_read_status;

/*
 * Read two bytes from `GE_debug_in` corresponding to the big endian
 * encoded size of the string, and then read that string and
 * return its value (null terminated).
 * The caller is reponsible for freeing its memory.
 * Return 0 if an error occured when reading from `GE_debug_in`.
 *
 * Thread-safe.
 * Note that the current thread is the only thread which
 * can modify the value of `GE_debug_in` and which can
 * access it. No need to protect it with a mutex.
 */
static char* GE_debug_get_string(GE_debug_read_status* status)
{
	int b1;
	int b2;
	size_t size = 0;
	size_t count;
	size_t total = 0;
	char* buf;

	*status = GE_DEBUG_READ_ERROR;
	if (!GE_debug_in) {
		*status = GE_DEBUG_READ_ERROR;
		return 0;
	}
	b1 = fgetc(GE_debug_in);
	if (b1 == EOF) {
		*status = feof(GE_debug_in) ? GE_DEBUG_READ_EOF : GE_DEBUG_READ_ERROR;
		GE_debug_in = NULL;
		return 0;
	}
	b2 = fgetc(GE_debug_in);
	if (b2 == EOF) {
		*status = GE_DEBUG_READ_ERROR;
		GE_debug_in = NULL;
		return 0;
	}
	size = ((uint16_t) b1 << 8) | (uint16_t) b2;
	/* Do not use `GE_malloc_atomic` to be sure that the GC
	 * does not get triggered and potentially calls `dispose`
	 * while the debugger is stopped.
	 */
	buf = (char*)malloc(size + 1);
	if (!buf) {
		*status = GE_DEBUG_READ_MEMORY_ERROR;
		GE_debug_in = NULL;
		return 0;
	}
	while (total != size) {
		count = fread(buf + total, 1, size - total, GE_debug_in);
		if (count <= 0) {
			free(buf);
			*status = GE_DEBUG_READ_ERROR;
			GE_debug_in = NULL;
			return 0;
		}
		total += count;
	}
	buf[size] = 0;
	*status = GE_DEBUG_READ_OK;
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
	GE_debug_read_status status = GE_DEBUG_READ_OK;
	int l_disconnected = 0;

	if (!GE_debug_in || !GE_debug_out) {
		/* Note that the current thread is the only thread which
		 * can modify the value of `GE_debug_in` and `GE_debug_out`.
		 * No need to protect their access with a mutex. */
		return;
	}
	type = GE_debug_get_string(&status);
	if (!type) {
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		if (status != GE_DEBUG_READ_EOF) {
			fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocolError\",\"body\":{},\"message\":\"'type' is missing in request\"}\n");
			fflush(GE_debug_out);
		}
		GE_unprotected_debug_continue_all();
		GE_debug_out = NULL;
		GE_debug_in = NULL;
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	id = GE_debug_get_string(&status);
	if (!id) {
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocolError\",\"body\":{},\"message\":\"'id' is missing in request\"}\n");
		fflush(GE_debug_out);
		GE_unprotected_debug_continue_all();
		GE_debug_out = NULL;
		GE_debug_in = NULL;
		free(type);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	command = GE_debug_get_string(&status);
	if (!command) {
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"'command' missing in request.\"}\n", id);
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocolError\",\"body\":{},\"message\":\"The Eiffel debugger connection is no longer available.\"}\n");
		fflush(GE_debug_out);
		GE_unprotected_debug_continue_all();
		GE_debug_out = NULL;
		GE_debug_in = NULL;
		free(type);
		free(id);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	} 
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);

	if(strcmp(command, "initialize") == 0) {
		/* Handle 'initialize'. */
		char* protocol_version;
		GE_debug_configuration_done = 0;
		protocol_version = GE_debug_get_string(&status);
		if (!protocol_version) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"'protocolVersion' missing in request '%s'.\"}\n", id, command);
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
		char* str;
		uint32_t bp_count;
		uint32_t i;
		uint32_t bp_line;
		GE_debug_file_breakpoints* breakpoints;
		source_path = GE_debug_get_string(&status);
		if (!source_path) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"'sourcePath' missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		breakpoints = GE_debug_breakpoints_for_file(source_path);
		free(source_path);
		if (breakpoints) {
			GE_unprotected_debug_disable_all_file_breakpoints(breakpoints);
		}
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"breakpoint count missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &bp_count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"breakpoint count missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"breakpoints\":[", id);
		for (i = 0; i < bp_count; i++) {
			if (i != 0) {
				fprintf(GE_debug_out, ",");
			}
			str = GE_debug_get_string(&status);
			if (!str) {
				fprintf(GE_debug_out, "{\"verified\":false,\"message\":\"breakpoint line number missing in request.\"}");
				continue;
			}
			if (sscanf(str, "%u", &bp_line) != 1) {
				fprintf(GE_debug_out, "{\"verified\":false,\"message\":\"Invalid line number %s.\"}", str);
				free(str);
				continue;
			}
			free(str);
			if (breakpoints) {
				GE_debug_breakpoint* bp = GE_debug_breakpoint_at_line(bp_line, breakpoints);
				if (bp) {
					bp->enabled = 1;
					fprintf(GE_debug_out, "{\"id\":%u,\"verified\":true,\"line\":%u}", bp->id, bp->last_line);
				} else {
					fprintf(GE_debug_out, "{\"verified\":false,\"line\":%u,\"message\":\"No breakpoint compiled at this position.\"}", bp_line);
				}
			} else {
				fprintf(GE_debug_out, "{\"verified\":false,\"line\":%u,\"message\":\"No feature compiled in this file.\"}", bp_line);
			}
		}
		fprintf(GE_debug_out, "]}}\n");

	} else if(strcmp(command, "setExceptionBreakpoints") == 0) {
		/* Handle 'setExceptionBreakpoints'. */
		char* l_filter;
		char* str;
		uint32_t l_count;
		uint32_t i;
		GE_unprotected_debug_disable_all_exception_breakpoints();
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"filter count missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &l_count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"filter count missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"breakpoints\":[", id);
		for (i = 0; i < l_count; i++) {
			if (i != 0) {
				fprintf(GE_debug_out, ",");
			}
			l_filter = GE_debug_get_string(&status);
			if (!l_filter) {
				fprintf(GE_debug_out, "{\"verified\":false,\"message\":\"Missing filter.\"}");
			} else if(strcmp(l_filter, "raised") == 0) {
				GE_debug_exception_breakpoint_raised = 1;
				fprintf(GE_debug_out, "{\"verified\":true}");
				free(l_filter);
			} else if(strcmp(l_filter, "uncaught") == 0) {
				GE_debug_exception_breakpoint_uncaught = 1;
				fprintf(GE_debug_out, "{\"verified\":true}");
				free(l_filter);
			} else if(strcmp(l_filter, "unretried") == 0) {
				GE_debug_exception_breakpoint_unretried = 1;
				fprintf(GE_debug_out, "{\"verified\":true}");
				free(l_filter);
			} else {
				fprintf(GE_debug_out, "{\"verified\":false,\"message\":\"Unknown filter %s.\"}", l_filter);
				free(l_filter);
			}
		}
		fprintf(GE_debug_out, "]}}\n");

	} else if(strcmp(command, "setExceptionCategories") == 0) {
		/* Handle 'setExceptionCategories'. */
		char* l_category;
		char* str;
		uint32_t l_count;
		uint32_t i;
		int l_category_error_reported = 0;
		int l_updated;
		GE_unprotected_debug_disable_all_exception_categories();
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"exception category count missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &l_count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"exception category count missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		for (i = 0; i < l_count; i++) {
			l_category = GE_debug_get_string(&status);
			if (!l_category) {
				if (!l_category_error_reported) {
					fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"Missing exception category.\"}\n", id);
				}
				goto GE_debug_receive_done;
			} else {
				l_updated = GE_unprotected_debug_enable_exception_category(l_category);
				if (!l_updated) {
					if (!l_category_error_reported) {
						fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"Unknown exception category %s.\"}\n", id, l_category);
						l_category_error_reported = 1;
					}
				}
				free(l_category);
			}
		}
		if (!l_category_error_reported) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		}

	} else if(strcmp(command, "threads") == 0) {
		/* Handle 'threads'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_threads_body();
		fprintf(GE_debug_out, "}\n");

	} else if(strcmp(command, "stackTrace") == 0) {
		/* Handle 'stackTrace'. */
		char* str;
		uint32_t thread_id;
		uint32_t start_frame;
		uint32_t levels;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start frame missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &start_frame) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start frame missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"levels missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &levels) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"levels missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_stack_trace_body(thread_id, start_frame, levels);
		fprintf(GE_debug_out, "}\n");

	} else if(strcmp(command, "scopes") == 0) {
		/* Handle 'scopes'. */
		char* str;
		uint32_t thread_id;
		uintptr_t frame_id;
		GE_call* l_frame;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "0x%016" EIF_POINTER_DISPLAY, &frame_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		l_frame = (GE_call*)frame_id;
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_scopes_body(thread_id, l_frame);
		fprintf(GE_debug_out, "}\n");

	} else if(strcmp(command, "argumentVariables") == 0) {
		/* Handle 'argumentVariables'. */
		char* str;
		uint32_t thread_id;
		uintptr_t frame_id;
		GE_call* l_frame;
		char* filter;
		uint32_t start;
		uint32_t count;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "0x%016" EIF_POINTER_DISPLAY, &frame_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		filter = GE_debug_get_string(&status);
		if (!filter) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"filter missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &start) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		l_frame = (GE_call*)frame_id;
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_argument_variables_body(thread_id, l_frame, filter, start, count);
		fprintf(GE_debug_out, "}\n");
		free(filter);

	} else if(strcmp(command, "localVariables") == 0) {
		/* Handle 'localVariables'. */
		char* str;
		uint32_t thread_id;
		uintptr_t frame_id;
		GE_call* l_frame;
		char* filter;
		uint32_t start;
		uint32_t count;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "0x%016" EIF_POINTER_DISPLAY, &frame_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"frame id missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		filter = GE_debug_get_string(&status);
		if (!filter) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"filter missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &start) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		l_frame = (GE_call*)frame_id;
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_local_variables_body(thread_id, l_frame, filter, start, count);
		fprintf(GE_debug_out, "}\n");
		free(filter);

	} else if(strcmp(command, "attributeVariables") == 0) {
		/* Handle 'attributeVariables'. */
		char* str;
		uintptr_t l_address;
		void* l_object;
		char* filter;
		uint32_t start;
		uint32_t count;
		EIF_TYPE_INDEX type_id;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"object address missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "0x%016" EIF_POINTER_DISPLAY, &l_address) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"object address missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"type id missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%hu", &type_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"type id missing in request 'variables'.\"}\n", id);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		filter = GE_debug_get_string(&status);
		if (!filter) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"filter missing in request 'variables'.\"}\n", id);
			goto GE_debug_receive_done;
		}
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &start) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"start missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(filter);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &count) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"count missing in request 'variables'.\"}\n", id);
			free(str);
			free(filter);
			goto GE_debug_receive_done;
		}
		free(str);
		l_object = (void*)l_address;
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,", id);
		GE_unprotected_debug_write_attribute_variables_body(l_object, type_id, filter, start, count);
		fprintf(GE_debug_out, "}\n");
		free(filter);

	} else if(strcmp(command, "continue") == 0) {
		/* Handle 'continue'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"allThreadsContinued\":true}}\n", id);
		GE_unprotected_debug_continue_all();

	} else if(strcmp(command, "pause") == 0) {
		/* Handle 'pause'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_unprotected_debug_pause_all();

	} else if(strcmp(command, "next") == 0) {
		/* Handle 'next'. */
		char* str;
		uint32_t thread_id;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_unprotected_debug_step_next(thread_id);

	} else if(strcmp(command, "stepIn") == 0) {
		/* Handle 'stepIn'. */
		char* str;
		uint32_t thread_id;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_unprotected_debug_step_in(thread_id);

	} else if(strcmp(command, "stepOut") == 0) {
		/* Handle 'stepOut'. */
		char* str;
		uint32_t thread_id;
		str = GE_debug_get_string(&status);
		if (!str) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			goto GE_debug_receive_done;
		}
		if (sscanf(str, "%u", &thread_id) != 1) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"thread id missing in request '%s'.\"}\n", id, command);
			free(str);
			goto GE_debug_receive_done;
		}
		free(str);
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_unprotected_debug_step_out(thread_id);

	} else if(strcmp(command, "disconnect") == 0) {
		/* Handle 'disconnect'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		GE_unprotected_debug_continue_all();
		l_disconnected = 1;
	
	} else {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{},\"message\":\"request '%s' not supported.\"}\n", id, command);
	}
GE_debug_receive_done:
	free(type);
	free(id);
	free(command);
	fflush(GE_debug_out);
	if (l_disconnected) {
		GE_debug_out = NULL;
		GE_debug_in = NULL;
	} else if (!GE_debug_in) {
		fprintf(GE_debug_out, "{\"type\":\"event\",\"event\":\"protocolError\",\"body\":{},\"message\":\"The Eiffel debugger connection is no longer available.\"}\n");
		fflush(GE_debug_out);
		GE_unprotected_debug_continue_all();
		GE_debug_out = NULL;
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
}

/*
 * Receive requests from VS Code Eiffel debugger adapter
 * and process them.
 *
 * Thread-safe.
 * Note that the current thread is the only thread
 * which can modify the value of `GE_debug_in`.
 * No need to protect their access with a mutex.
 */
static void GE_debug_receive_requests()
{
	while (GE_debug_in) {
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

/*
 * Initialize debugging facilities. *
 * Thread-safe.
 * Note that the current thread is the only thread
 * currently running. No need to protect anything
 * with a mutex.
 */
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
			GE_debug_in = _fdopen(debug_pipe_in, "rb");
#else
			GE_debug_in = fdopen(debug_pipe_in, "rb");
#endif
			if (GE_debug_in) {
#if defined(_MSC_VER)
				GE_debug_out = _fdopen(debug_pipe_out, "wb");
#else
				GE_debug_out = fdopen(debug_pipe_out, "wb");
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
			while (!GE_debug_configuration_done && GE_debug_in) {
				GE_debug_receive_request();
			}
			if (GE_debug_in) {
				GE_debug_thread_create_with_attr(&GE_debug_receive_requests, 0);
			}
		}
	}
}

/*
 * Is `a_breakpoint` enabled, or is it the following step (next, in or out) in the expected thread?
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - Mutex of `a_thread`.
 */
static int GE_unprotected_debug_stoppable_breakpoint(GE_context* a_thread, GE_debug_breakpoint* a_breakpoint)
{
	uint32_t count = 0;
	GE_call* l_call;

	if (a_breakpoint->enabled) {
		return 1;
	}
	if (GE_debug_step_next_thread_id > 0 && GE_debug_step_level > 0) {
		if (a_thread->debug_thread_id == GE_debug_step_next_thread_id) {
			l_call = a_thread->call;
			while (l_call && count <= GE_debug_step_level) {
				count++;
				l_call = l_call->caller;
			}
			if (count <= GE_debug_step_level) {
				return 1;
			}
		}
		return 0;
	}
	if (GE_debug_step_in_thread_id > 0 && GE_debug_step_level > 0) {
		if (a_thread->debug_thread_id == GE_debug_step_in_thread_id) {
			int l_scoop_initialization = 0;
			l_call = a_thread->call;
			while (l_call) {
				if (strcmp(l_call->feature_name, "SCOOP initialization") == 0) {
					l_scoop_initialization = 1;
					break;
				}
				l_call = l_call->caller;
			}
			return (!l_scoop_initialization);
		}
		return 0;
	}
	if (GE_debug_step_out_thread_id > 0 && GE_debug_step_level > 0) {
		if (a_thread->debug_thread_id == GE_debug_step_out_thread_id) {
			l_call = a_thread->call;
			while (l_call && count <= GE_debug_step_level) {
				count++;
				l_call = l_call->caller;
			}
			if (count < GE_debug_step_level) {
				return 1;
			}
		}
		return 0;
	}
	return 0;
}

/*
 * Action executed when breakpoint `a_breakpoint` is hit.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of `a_thread`.
 */
void GE_debug_hit_breakpoint(GE_context* a_thread, GE_debug_breakpoint* a_breakpoint)
{
	if (!GE_debug_mutex) {
		/* Not initialized yet.
		 * This might happen when initializing Eiffel exception
		 * handlers which execute Eiffel code behind the scene. */
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	while (a_thread->debug_status_pending) {
		/* Wait for the global debugger status to be updated. */
		a_thread->debug_status_pending = 0;
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	}
	GE_call* l_call = a_thread->call;
	if (l_call) {
		l_call->line = a_breakpoint->last_line;
		l_call->column = 1;
	}
	if (!GE_debug_is_stopped && !GE_debug_is_stopping && !GE_unprotected_debug_stoppable_breakpoint(a_thread, a_breakpoint)) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		return;
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (!GE_debug_out) {
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	if (!GE_debug_is_stopped && !GE_debug_is_stopping && !GE_unprotected_debug_stoppable_breakpoint(a_thread, a_breakpoint)) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	GE_unprotected_debug_set_status_pending(a_thread);
	if (!GE_debug_is_stopped) {
		if (!GE_debug_stopped_thread_id) {
			GE_debug_stopped_thread_id = a_thread->debug_thread_id;
			if (a_breakpoint->enabled) {
				GE_debug_stopped_reason = "breakpoint";
			} else if (!GE_debug_is_stopping) {
				GE_debug_stopped_reason = "step";
			} else {
				GE_debug_stopped_reason = "pause";
			}
			GE_debug_stopped_exception_code = 0;
			GE_debug_stopped_exception_tag = 0;
		}
	}
	if (!GE_debug_is_stopped && !GE_debug_is_stopping) {
		GE_debug_is_stopping = 1;
		GE_debug_step_next_thread_id = 0;
		GE_debug_step_in_thread_id = 0;
		GE_debug_step_out_thread_id = 0;
		GE_debug_step_level = 0;
	}
	if (!a_thread->is_stopped) {
		a_thread->is_stopped = 1;
	}
	if (!GE_debug_is_stopped) {
		GE_unprotected_debug_check_and_send_all_stopped(a_thread);
	}
	GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
	while (a_thread->is_stopped) {
		GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
}

/*
 * Can `a_thread` be stopped on an exception of code `a_code` ?
 * 
 * Not thread-safe.
 * Need to be protected by:
 * - Mutex of `a_thread`.
 */
static int GE_unprotected_debug_stoppable_exception_breakpoint(GE_context* a_thread, long code)
{
	if (code < 1 || code > GE_EX_NEX) {
		return 0;
	}
	if (!GE_debug_exception_breakpoint_categories[code]) {
		return 0;
	}
	if (GE_debug_exception_breakpoint_raised) {
		return 1;
	}
	if (GE_debug_exception_breakpoint_uncaught) {
		GE_rescue* l_rescue;
		int l_uncaught = 1;
		l_rescue = a_thread->last_rescue;
		while (l_rescue) {
			if (l_rescue->is_eiffel) {
				l_uncaught = 0;
				break;
			}
			l_rescue = l_rescue->previous;
		}
		if (l_uncaught) {
			return 1;
		}
	}
	if (GE_debug_exception_breakpoint_unretried) {
		GE_rescue* l_rescue;
		int l_unretried = 1;
		l_rescue = a_thread->last_rescue;
		while (l_rescue) {
			if (l_rescue->is_eiffel && l_rescue->has_retry) {
				l_unretried = 0;
				break;
			}
			l_rescue = l_rescue->previous;
		}
		if (l_unretried) {
			return 1;
		}
	}
	return 0;
}

/*
 * Action executed when exception breakpoint is hit.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of `a_thread`.
 */
void GE_debug_hit_exception_breakpoint(GE_context* a_thread, long code, const char* tag)
{
	if (!GE_debug_mutex) {
		/* Not initialized yet.
		 * This might happen when initializing Eiffel exception
		 * handlers which execute Eiffel code behind the scene. */
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	while (a_thread->debug_status_pending) {
		/* Wait for the global debugger status to be updated. */
		a_thread->debug_status_pending = 0;
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	}
	if (!GE_debug_is_stopped && !GE_debug_is_stopping && !GE_unprotected_debug_stoppable_exception_breakpoint(a_thread, code)) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		return;
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (!GE_debug_out) {
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	if (!GE_debug_is_stopped && !GE_debug_is_stopping && !GE_unprotected_debug_stoppable_exception_breakpoint(a_thread, code)) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	GE_unprotected_debug_set_status_pending(a_thread);
	if (!GE_debug_is_stopped) {
		if (!GE_debug_stopped_thread_id) {
			GE_debug_stopped_thread_id = a_thread->debug_thread_id;
			GE_debug_stopped_reason = "exception";
			GE_debug_stopped_exception_code = code;
			GE_debug_stopped_exception_tag = tag;
		}
	}
	if (!GE_debug_is_stopped && !GE_debug_is_stopping) {
		GE_debug_is_stopping = 1;
		GE_debug_step_next_thread_id = 0;
		GE_debug_step_in_thread_id = 0;
		GE_debug_step_out_thread_id = 0;
		GE_debug_step_level = 0;
	}
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
	while (a_thread->is_stopped) {
		GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
}

/*
 * Set `is_blocking` status of `a_thread`.
 * 
 * Thread-safe.
 * Protected by:
 * - `GE_debug_mutex`.
 * - Mutex of `a_thread`.
 */
void GE_debug_set_blocking(GE_context* a_thread, uint8_t a_value)
{
	if (!GE_debug_mutex) {
		/* Not initialized yet.
		 * This might happen when initializing Eiffel exception
		 * handlers which execute Eiffel code behind the scene. */
		a_thread->is_blocking = a_value;
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	while (a_thread->debug_status_pending) {
		/* Wait for the global debugger status to be updated. */
		a_thread->debug_status_pending = 0;
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	}
	a_thread->is_blocking = a_value;
	if (!GE_debug_is_stopped && !GE_debug_is_stopping) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		return;
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
	GE_mutex_lock((EIF_POINTER)GE_debug_mutex);
	if (!GE_debug_out) {
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
	GE_mutex_lock((EIF_POINTER)a_thread->debug_mutex);
	if (!GE_debug_is_stopped && !GE_debug_is_stopping) {
		GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
		GE_mutex_unlock((EIF_POINTER)GE_debug_mutex);
		return;
	}
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
	while (a_thread->is_stopped) {
		GE_condition_variable_wait((EIF_POINTER)a_thread->debug_condition_variable, (EIF_POINTER)a_thread->debug_mutex);
	}
	GE_mutex_unlock((EIF_POINTER)a_thread->debug_mutex);
}

/*
 * Set position of `call`.
 * 
 * Thread-safe.
 * Protected by:
 * - Mutex of `a_thread`.
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
 * - Mutex of `a_thread`.
 */
void GE_debug_set_call_location(GE_context* a_thread, GE_call* call, const char* class_name, const char* filename)
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
