/*
	description:

		"C functions used for debugging"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2026, Eric Bezault and others"
	license: "MIT License"
*/

#ifndef GE_DEBUG_H
#define GE_DEBUG_H
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifdef GE_DEBUG_MODE

#ifndef GE_EXCEPTION_H
#include "ge_exception.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Debugger breakpoint.
 */
typedef volatile struct {
	uint32_t volatile id;
	uint32_t volatile first_line;
	uint32_t volatile last_line;
	char volatile enabled;
} GE_debug_breakpoint;

/*
 * All debugger breakpoints in a given file.
 */
typedef volatile struct {
	const char* volatile filename;
	GE_debug_breakpoint** volatile breakpoints;
	uint32_t volatile breakpoint_count;
} GE_debug_file_breakpoints;

/* All breakpoints in the Eiffel system. */
extern GE_debug_file_breakpoints* GE_debug_breakpoints[];

/* Number of items in `GE_debug_breakpoints`. */
extern uint32_t GE_debug_breakpoint_count;

/* Initialize debugging facilities. */
extern void GE_debug_init(GE_context* a_thread);

/* Add `a_thread` to the list of Eiffel threads known by the debugger. */
extern void GE_debug_register_thread(GE_context* a_thread);

/* Remove `a_thread` from the list of Eiffel threads known by the debugger. */
extern void GE_debug_remove_thread(GE_context* a_thread);

/* Action executed when breakpoint `a_breakpoint` is hit.*/
#define GE_bp(a,b) GE_debug_hit_breakpoint((a),(b))
extern void GE_debug_hit_breakpoint(GE_context* a_thread, GE_debug_breakpoint* a_breakpoint);

/* Set `is_blocking` status of `a_thread`. */
extern void GE_debug_set_blocking(GE_context* a_thread, int a_value);

/* Set position of `call`. */
extern void GE_debug_set_call_position(GE_context* a_thread, GE_call* call, uint32_t line, uint32_t column);

/* Set class_name/filename of `call`. */
extern void GE_debug_set_call_location(GE_context* a_thread, GE_call* call, char* class_name, char* filename);

#ifdef __cplusplus
}
#endif

#endif
#endif
