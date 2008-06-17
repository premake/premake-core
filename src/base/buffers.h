/**
 * \file   buffers.h
 * \brief  Shared working buffer system.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 *
 * \defgroup buffers Buffers
 * \ingroup  base
 *
 * A shared working buffer collection. A buffer can be requested from the system, filled,
 * and passed around for a short period of time. This system allows transient string values
 * to be returned from functions and immediately used without having to resort to
 * full-blown string objects, and the ownership issues that would entail.
 *
 * @{
 */
#if !defined(PREMAKE_BUFFER_H)
#define PREMAKE_BUFFER_H

extern const int BUFFER_SIZE;

char* buffers_next(void);

#endif
/** @} */

