/**
 * \file   buffers.h
 * \brief  Shared working buffer system.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_BUFFER_H)
#define PREMAKE_BUFFER_H

extern const int BUFFER_SIZE;

char* buffers_next(void);

#endif

