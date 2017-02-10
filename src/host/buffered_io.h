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

void buffer_init(Buffer* b);
void buffer_destroy(Buffer* b);

void buffer_puts(Buffer* b, const void* ptr, size_t len);
void buffer_printf(Buffer* b, const char* s, ...);

#endif