#include "../premake_internal.h"
#include <stdlib.h>
#include <string.h>
#include "premake.h"

struct pmk_Buffer
{
	size_t capacity;
	size_t length;
	char*  data;
};


pmk_Buffer* pmk_bufferInit()
{
	pmk_Buffer* b = (pmk_Buffer*)malloc(sizeof(struct pmk_Buffer));
	b->capacity = 0;
	b->length = 0;
	b->data = NULL;
	return (b);
}


void pmk_bufferClose(pmk_Buffer* b)
{
	free(b->data);
	b->capacity = 0;
	b->length = 0;
	b->data = NULL;
	free(b);
}


const char* pmk_bufferContents(pmk_Buffer* b)
{
	return (b->data);
}


size_t pmk_bufferLen(pmk_Buffer* b)
{
	return (b->length);
}


void pmk_bufferPuts(pmk_Buffer* b, const char* ptr, size_t len)
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


void pmk_bufferPrintf(pmk_Buffer* b, const char *fmt, ...)
{
	char text[2048];
	int len;
	va_list args;
	va_start(args, fmt);
	len = vsnprintf(text, sizeof(text) - 1, fmt, args);
	va_end(args);
	pmk_bufferPuts(b, text, len);
}
