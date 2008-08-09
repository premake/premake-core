/**
 * \file   vs200x_solution.c
 * \brief  Visual Studio multiple-version solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "vs200x_solution.h"


/**
 * Create a new output stream for a solution, and make it active for subsequent writes.
 */
int vs200x_solution_create(Solution sln, Stream strm)
{
	/* create the solution file */
	const char* filename = solution_get_filename(sln, NULL, ".sln");
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(solution_get_session(sln), strm);
	return OKAY;
}
