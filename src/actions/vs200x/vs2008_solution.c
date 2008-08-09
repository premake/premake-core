/**
 * \file   vs2008_solution.c
 * \brief  Visual Studio 2008 solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "vs200x_solution.h"


/**
 * Write the Visual Studio 2008 solution file signature.
 */
int vs2008_solution_signature(Solution sln, Stream strm)
{
	int z;
	UNUSED(sln);
	stream_set_newline(strm, "\r\n");
	z  = stream_write_unicode_marker(strm);
	z |= stream_writeline(strm, "");
	z |= stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 10.00");
	z |= stream_writeline(strm, "# Visual Studio 2008");
	return z;
}
