/**
 * \file   buffered_io.h
 * \brief  provide buffered io.
 * \author Copyright (c) 2014
 */
#ifndef buffered_io_h
#define buffered_io_h

#include <stdio.h>

typedef struct struct_Buffer
{
	size_t capacity;
	size_t length;
	char*  data;
} Buffer;

void premake_buffer_init(Buffer* b);
void premake_buffer_destroy(Buffer* b);

void premake_buffer_puts(Buffer* b, const void* ptr, size_t len);
void premake_buffer_printf(Buffer* b, const char* s, ...);

#endif
