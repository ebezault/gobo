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
	} else if(strcmp(command, "initialize") == 0) {
		/* Handle 'initialize'. */
		char* protocol_version;
		protocol_version = GE_debug_get_string(GE_debug_in);
		if (!protocol_version) {
			fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"'protocolVersion' missing in request '%s'.\"}\n", id, command);
			fflush(GE_debug_out);
			goto GE_debug_receive_done;
		}
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{\"protocolVersion\":1}}\n", id);
		fflush(GE_debug_out);
		GE_free(protocol_version);
	} else if(strcmp(command, "configurationDone") == 0) {
		/* Handle 'configurationDone'. */
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":true,\"body\":{}}\n", id);
		fflush(GE_debug_out);
		GE_debug_configuration_done = 1;
	} else {
		fprintf(GE_debug_out, "{\"type\":\"response\",\"id\":%s,\"success\":false,\"body\":{}, \"message\":\"request '%s' not supported.\"}\n", id, command);
		fflush(GE_debug_out);
	}
GE_debug_receive_done:
	GE_free(type);
	GE_free(id);
	GE_free(command);
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

#ifdef __cplusplus
}
#endif

#endif
