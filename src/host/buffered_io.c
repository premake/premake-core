/**
 * \file   buffered_io.c
 * \brief  provide buffered io.
 * \author Copyright (c) 2014
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "buffered_io.h"

void buffer_init(Buffer* b)
{
	b->capacity = 0;
	b->length = 0;
	b->data = NULL;
}

void buffer_destroy(Buffer* b)
{
	free(b->data);
	b->capacity = 0;
	b->length = 0;
	b->data = NULL;
}

void buffer_puts(Buffer* b, const void* ptr, size_t len)
{
	char* data;

	size_t required = b->length + len;
	if (required > b->capacity)
	{
		size_t cap = b->capacity;
		while (required > cap)
		{
			cap = (cap * 3) / 2;
			if (cap <= 65536)
				cap = 65536;
		}

		data = (char*)calloc(cap, 1);
		if (b->length > 0)
		{
			memcpy(data, b->data, b->length);
			free(b->data);
		}
		b->data = data;
		b->capacity = cap;
	}

	memcpy(b->data + b->length, ptr, len);
	b->length += len;
}

void buffer_printf(Buffer* b, const char *fmt, ...)
{
	char text[2048];
	int len;
	va_list args;
	va_start(args, fmt);
	len = vsnprintf(text, sizeof(text) - 1, fmt, args);
	va_end(args);
	buffer_puts(b, text, len);
}

// -- Lua wrappers ----------------------------------------

int buffered_new(lua_State* L)
{
	Buffer* b = (Buffer*)malloc(sizeof(Buffer));
	buffer_init(b);
	lua_pushlightuserdata(L, b);
	return 1;
}

int buffered_write(lua_State* L)
{
	size_t len;
	const char *s = luaL_checklstring(L, 2, &len);
	Buffer* b = (Buffer*)lua_touserdata(L, 1);

	buffer_puts(b, s, len);
	return 0;
}

int buffered_writeln(lua_State* L)
{
	size_t len;
	const char *s = luaL_optlstring(L, 2, NULL, &len);
	Buffer* b = (Buffer*)lua_touserdata(L, 1);

	if (s != NULL)
		buffer_puts(b, s, len);
	buffer_puts(b, "\r\n", 2);
	return 0;
}

int buffered_close(lua_State* L)
{
	Buffer* b = (Buffer*)lua_touserdata(L, 1);
	buffer_destroy(b);
	free(b);
	return 0;
}

int buffered_tostring(lua_State* L)
{
	Buffer* b = (Buffer*)lua_touserdata(L, 1);
	size_t len = b->length;

	// trim string for _eol of line at the end.
	if (len > 0 && b->data[len-1] == '\n')
		--len;
	if (len > 0 && b->data[len-1] == '\r')
		--len;

	if (len > 0)
		// push data into a string.
		lua_pushlstring(L, b->data, len);
	else
		lua_pushstring(L, "");

	return 1;
}
