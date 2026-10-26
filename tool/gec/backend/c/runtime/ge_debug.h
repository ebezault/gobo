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

#ifdef __cplusplus
extern "C" {
#endif

/* Initialize debugging facilities. */
extern void GE_debug_init(void);

#ifdef __cplusplus
}
#endif

#endif
