/**
 * \file   vs200x_solution.c
 * \brief  Visual Studio 200x solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "vs200x_solution.h"
#include "base/error.h"


/**
 * Create a new output stream for a solution, and make it active for subsequent writes.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs200x_solution_create(Session sess, Solution sln, Stream strm)
{
	/* create the solution file */
	const char* filename = solution_get_filename(sln, NULL, ".sln");
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(sess, strm);
	return OKAY;
}


/**
 * Write the solution file signature block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs200x_solution_signature(Session sess, Solution sln, Stream strm)
{
	int version, z;

	assert(sess);
	assert(strm);
	sln = 0;  /* unused */

	stream_set_newline(strm, "\r\n");
	z = stream_write_unicode_marker(strm);

	version = vs200x_get_target_version(sess);
	switch (version)
	{
	case 2002:
		z |= stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 7.00");
		break;
	case 2003:
		z |= stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 8.00");
		break;
	case 2005:
		z |= stream_writeline(strm, "");
		z |= stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 9.00");
		z |= stream_writeline(strm, "# Visual Studio 2005");
		break;
	}

	return z;
}
