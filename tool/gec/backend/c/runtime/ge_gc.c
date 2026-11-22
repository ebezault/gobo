/*
	description:

		"C functions used to access garbage collector facilities"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2007-2024, Eric Bezault and others"
	license: "MIT License"
*/

#ifndef GE_GC_C
#define GE_GC_C
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifndef GE_GC_H
#include "ge_gc.h"
#endif
#ifdef GE_USE_BOEHM_GC
#ifndef GE_TYPES_H
#include "ge_types.h"
#endif
#ifdef GE_USE_THREADS
#ifndef GE_THREAD_H
#include "ge_thread.h"
#endif
#endif
#ifdef GE_DEBUG_MODE
#ifndef GE_DEBUG_H
#include "ge_debug.h"
#endif
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Allocate memory that does not contain pointers to collectable objects.
 * The allocated memory is zeroed.
 * The allocated object is itself not collectable.
 * Do not raise an exception when no-more-memory.
 */
#ifdef GE_USE_BOEHM_GC
void* GE_unprotected_calloc_atomic_uncollectable(size_t nelem, size_t elsize)
{
	void* new_p;

	new_p = GC_malloc_atomic_uncollectable(nelem * elsize);
	if (new_p) {
		GE_memset(new_p, 0, nelem * elsize);
	}
	return new_p;
}
#endif

/*
 * Allocate more memory for the given pointer.
 * The reallocated pointer keeps the same properties (e.g. atomic or not, collectable or not).
 * The extra allocated memory is zeroed.
 * Do not raise an exception when no-more-memory.
 */
void* GE_unprotected_recalloc(void* p, size_t old_nelem, size_t new_nelem, size_t elsize)
{
	void* new_p;
	new_p = GE_unprotected_realloc(p, new_nelem * elsize);
	if (new_p) {
		GE_memset(((char*)new_p) + (old_nelem * elsize), 0, (new_nelem - old_nelem) * elsize);
	}
	return new_p;
}

#ifdef GE_USE_BOEHM_GC
/*
 * Call dispose routine on object `C'.
 */
void GE_boehm_dispose(void* C, void* disp) {
	GE_context* l_current_context = 0;
	GE_context* l_main_context;
	GE_context* ac;
#if defined(GE_DEBUG_MODE)
	GE_call tc = {(void* volatile)C,"","GC dispose","",0,0,0};
#elif defined(GE_USE_CURRENT_IN_EXCEPTION_TRACE)
	GE_call tc = {(void* volatile)C,"","GC dispose",0};
#else
	GE_call tc = {"","GC dispose",0};
#endif
	uint8_t volatile in_assertion;
	GE_rescue* volatile last_rescue;
	uint32_t volatile in_rescue;
	uint8_t volatile in_qualified_call;
	uint8_t volatile preconditions_enabled;
	char volatile raising_exception;
	long volatile exception_code;
	const char* volatile exception_tag;
	int volatile signal_number;

	l_main_context = GE_main_context;
#ifdef GE_USE_THREADS
	l_current_context = GE_unprotected_thread_current_context();
#else
	l_current_context = l_main_context;
#endif
	if (l_current_context) {
		/* Executed from an Eiffel thread. */
		ac = l_current_context;
	} else {
		GE_context l_context;
#ifdef GE_DEBUG_MODE
		GE_mutex_lock((EIF_POINTER)l_main_context->debug_mutex);
#endif
		l_context = *l_main_context;
#ifdef GE_DEBUG_MODE
		GE_mutex_unlock((EIF_POINTER)l_main_context->debug_mutex);
#endif
		ac = &l_context;
		ac->call = 0;
	}
	tc.caller = ac->call;
	ac->call = &tc;
	in_assertion = ac->in_assertion;
	ac->in_assertion = 0;
	last_rescue = ac->last_rescue;
	ac->last_rescue = 0;
	in_rescue = ac->in_rescue;
	ac->in_rescue = 0;
	in_qualified_call = ac->in_qualified_call;
	ac->in_qualified_call = 0;
	preconditions_enabled = ac->preconditions_enabled;
	ac->preconditions_enabled = 0;
	raising_exception = ac->raising_exception;
	ac->raising_exception = 0;
	exception_code = ac->exception_code;
	ac->exception_code = 0;
	exception_tag = ac->exception_tag;
	ac->exception_tag = 0;
	signal_number = ac->signal_number;
	ac->signal_number = 0;
#ifdef GE_DEBUG_MODE
	if (ac != l_current_context) {
		ac->next_thread = 0;
		ac->is_blocking = 0;
		ac->is_stopped = 0;
		ac->debug_mutex = (EIF_MUTEX_TYPE*)GE_mutex_create();
		ac->debug_condition_variable = (EIF_COND_TYPE*)GE_condition_variable_create();
		GE_debug_register_thread(ac);
	}
#endif
	((GE_types[((EIF_REFERENCE)C)->id][0]).dispose)(ac, (EIF_REFERENCE) C);
	ac->in_assertion = in_assertion;
	ac->last_rescue = last_rescue;
	ac->in_rescue = in_rescue;
	ac->in_qualified_call = in_qualified_call;
	ac->preconditions_enabled = preconditions_enabled;
	ac->raising_exception = raising_exception;
	ac->exception_code = exception_code;
	ac->exception_tag = exception_tag;
	ac->signal_number = signal_number;
	ac->call = tc.caller;
#ifdef GE_DEBUG_MODE
	if (ac != l_current_context) {
		GE_debug_remove_thread(ac);
		GE_mutex_destroy(ac->debug_mutex);
		GE_condition_variable_destroy(ac->debug_condition_variable);
	}
#endif
}

/*
 * Call dispose routine `disp' on once-per-object data `data'.
 */
void GE_boehm_dispose_once_per_object_data(void* data, void* disp) {
	((void (*) (void*)) disp)(data);
}
#endif

/* The C side protects an object. */
EIF_OBJECT eif_protect(EIF_REFERENCE object)
{
#ifdef GE_USE_BOEHM_GC
	EIF_REFERENCE* result = (EIF_REFERENCE*)GC_malloc_uncollectable(sizeof(EIF_REFERENCE));
	*result = object;
	return (EIF_OBJECT)result;
#else
	return (EIF_OBJECT)object;
#endif
}

/* The C side weans adopted object. */
EIF_REFERENCE eif_wean(EIF_OBJECT object)
{
#ifdef GE_USE_BOEHM_GC
	EIF_REFERENCE result = eif_access(object);
	GE_free(object);
	return result;
#else
	return (EIF_REFERENCE)object;
#endif
}

#ifdef __cplusplus
}
#endif

#endif
