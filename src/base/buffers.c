/**
 * \file   buffers.c
 * \brief  Shared working buffer system.
 * \author Copyright (c) 2007-2007 Jason Perkins and the Premake project
 * 
 * \note I need to do a lot of string building operations in Premake. Rather than
 * constantly creating, resizing, and releasing (and forgetting to release)
 * dynamic string buffers, I use this shared buffer pool instead. Each request
 * to buffer_next() returns the next buffer in the list. Pointers to the buffers 
 * can be safely passed around, and I don't need to remember to release anything 
 * when I'm done. The buffers should only be used for transient values, obviously.
 * If you need to keep a value around for any length of time copy it to a string.
 *
 * \note The size and number of the buffers is arbitrary; I just picked some numbers
 * that seemed big enough.
 */

#include <stdlib.h>
#include "premake.h"
#include "base/buffers.h"

/** The size of an individual buffer, in bytes. */
const int BUFFER_SIZE = 0x4000;

/** The number of buffers stored in the pool */
static const int NUM_BUFFERS = 64;

/** The pool of buffers */
static char** buffers = NULL;

/** The index of the next available buffer */
static int next = 0;


/**
 * Clean up after the buffer system. Called by atexit().
 */
static void buffers_destroy(void)
{
	if (buffers != NULL)
	{
		int i;
		for (i = 0; i < NUM_BUFFERS; ++i)
		{
			free(buffers[i]);
		}
		free(buffers);
	}
}


/**
 * Initialize the buffer system.
 */
static void buffers_create(void)
{
	int i;
	buffers = (char**)malloc(sizeof(char*) * NUM_BUFFERS);
	for (i = 0; i < NUM_BUFFERS; ++i)
	{
		buffers[i] = (char*)malloc(BUFFER_SIZE);
	}
	next = 0;
	atexit(buffers_destroy);
}


/**
 * Get a clean buffer.
 * \returns An empty buffer.
 */
char * buffers_next()
{
	/* if this is the first call, initialize the buffer system */
	if (buffers == NULL)
		buffers_create();

	next++;
	if (next == NUM_BUFFERS)
		next = 0;

	/* initialize new buffers to empty string */
	buffers[next][0] = '\0';
	return buffers[next];
}
