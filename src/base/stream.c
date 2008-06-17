/**
 * \file   stream.c
 * \brief  Output stream handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "base/error.h"
#include "base/dir.h"
#include "base/path.h"
#include "base/stream.h"


DEFINE_CLASS(Stream)
{
	FILE* file;
	const char* newline;
	char* buffer;
};


static struct Stream_impl Console_impl = { NULL, "\n", NULL };


/**
 * The console output stream.
 * Use the stream_write() functions and this stream object instead
 * of the usual C functions like printf(). The stream functions have
 * more features -- such as setting the line ending sequence -- and
 * can be captured for automated testing.
 */
Stream Console = &Console_impl;


/**
 * Create a new file output stream, overwriting any existing file.
 * \param   filename   The name of the file to create.
 * \returns A new file stream.
 */
Stream stream_create_file(const char* filename)
{
	Stream strm;
	const char* dirname;
	FILE* file;

	/* make sure the directory exists before writing to it */
	dirname = path_directory(filename);
	if (dir_create(dirname) != OKAY)
	{
		return NULL;
	}

	/* create the file */
	file = fopen(filename, "wb");
	if (file == NULL)
	{
		error_set("Unable to open file %s", filename);
		return NULL;
	}

	/* build the stream object */
	strm = stream_create_null();
	strm->file = file;
	return strm;
}


/**
 * Create a "null" stream, which discards any writes; intended for automated testing. 
 * \returns A new stream object.
 */
Stream stream_create_null()
{
	Stream strm = ALLOC_CLASS(Stream);
	strm->file = NULL;
	strm->newline = "\n";
	strm->buffer = NULL;
	return strm;
}


/**
 * Close a stream and release the associated memory.
 * \param strm   The stream to close.
 */
void stream_destroy(Stream strm)
{
	assert(strm);
	if (strm != Console)
	{
		if (strm->file != NULL)
		{
			fclose(strm->file);
		}
		free(strm);
	}
}


/**
 * Capture the text written to a stream into a buffer. 
 * When a stream is captured all text is written to the buffer, and
 * output to the associated file is blocked. 
 * \param strm    The stream to capture.
 * \param buffer  The buffer to contain the captured text. No checks are made
 *                on the size of the buffer while writing, so use carefully.
 *                May be NULL to disable buffering.
 */
void stream_set_buffer(Stream strm, char* buffer)
{
	assert(strm);
	strm->buffer = buffer;
	strm->buffer[0] = '\0';
}


/**
 * Set the newline character sequence.
 * \param strm    The stream to set.
 * \param newline The EOL sequence.
 */
void stream_set_newline(Stream strm, const char* newline)
{
	assert(strm);
	strm->newline = newline;
}


/**
 * Write a formatted list of strings.
 * \param   strm    The stream to which to write.
 * \param   strs    The list of strings to write.
 * \param   start   The start string, always written first, even if there are no items in the list.
 * \param   prefix  A prefix string, to be written before each item.
 * \param   postfix A postfix string, to be written after each item.
 * \param   infix   An infix strings, to write between items, after the
 *                  previous postfix string and before the next prefix.
 * \param   end     The end string, always written last, even if there are no items in the list.
 * \returns OKAY if successful.
 */
int stream_write_strings(Stream strm, Strings strs, const char* start, const char* prefix, const char* postfix, const char* infix, const char* end)
{
	int i, n, z;
	
	z = stream_write(strm, start);

	n = strings_size(strs);
	for (i = 0; i < n; ++i)
	{
		const char* value = strings_item(strs, i);
		if (i > 0) z |= stream_write(strm, infix);
		z |= stream_write(strm, prefix);
		z |= stream_write(strm, value);
		z |= stream_write(strm, postfix);
	}

	z |= stream_write(strm, end);
	return z;
}


/**
 * Write a formatted list of strings, followed by a newline.
 * \param   strm    The stream to which to write.
 * \param   strs    The list of strings to write.
 * \param   start   The start string, always written first, even if there are no items in the list.
 * \param   prefix  A prefix string, to be written before each item.
 * \param   postfix A postfix string, to be written after each item.
 * \param   infix   An infix strings, to write between items, after the
 *                  previous postfix string and before the next prefix.
 * \returns OKAY if successful.
 */
int stream_writeline_strings(Stream strm, Strings strs, const char* start, const char* prefix, const char* postfix, const char* infix)
{
	int i, n, z;
	
	z = stream_write(strm, start);

	n = strings_size(strs);
	for (i = 0; i < n; ++i)
	{
		const char* value = strings_item(strs, i);
		if (i > 0) z |= stream_write(strm, infix);
		z |= stream_write(strm, prefix);
		z |= stream_write(strm, value);
		z |= stream_write(strm, postfix);
	}

	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Format and print a string using printf-style codes and a variable argument list.
 * \param   strm    The stream to which to write.
 * \param   value   The value to print; may contain printf-style formatting codes.
 * \param   args    A variable argument list to populate the printf-style codes in `value`.
 * \returns OKAY if successful.
 */
int stream_vprintf(Stream strm, const char* value, va_list args)
{
	if (strm->buffer)
	{
		/* write to the end of the current contents of the buffer */
		char* start = strm->buffer + strlen(strm->buffer);
		vsprintf(start, value, args);
	}
	else if (strm == Console)
	{
		vfprintf(stdout, value, args);
	}
	else if (strm->file)
	{
		vfprintf(strm->file, value, args);
	}
	return OKAY;
}


/**
 * Write a string value to a stream.
 * \param   strm   The stream.
 * \param   value  The value to append to the stream.
 * \returns OKAY is successful.
 */
int stream_write(Stream strm, const char* value, ...)
{
	int status;
	va_list args;

	va_start(args, value);
	status = stream_vprintf(strm, value, args);
	va_end(args);
	
	return status;
}


/**
 * Write N copies of a string to a stream.
 * \param   strm      The stream to which to write.
 * \param   value     The string to write.
 * \param   n         The number of copies to write.
 * \returns OKAY if successful.
 */
int stream_write_n(Stream strm, const char* value, int n)
{
	int i, z = OKAY;
	for (i = 0; i < n; ++i)
	{
		z |= stream_write(strm, value);
	}
	return z;
}


/**
 * Writes the Unicode encoding marker sequence into the stream.
 * \param   strm      The stream to which to write.
 */
int stream_write_unicode_marker(Stream strm)
{
	return stream_write(strm, "\357\273\277");
}


/**
 * Write a string value, followed by a newline, to a stream.
 * \param   strm   The stream.
 * \param   value  The value to append to the stream.
 * \returns OKAY if successful.
 */
int stream_writeline(Stream strm, const char* value, ...)
{
	int status;
	va_list args;

	va_start(args, value);
	status = stream_vprintf(strm, value, args);
	status |= stream_write(strm, strm->newline);
	va_end(args);

	return status;
}
