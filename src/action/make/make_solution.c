/**
 * \file   make_solution.c
 * \brief  Makefile solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "action/make/make.h"
#include "action/make/make_solution.h"
#include "base/error.h"


/**
 * Create a new output stream for a solution, and make it active for subsequent writes.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int make_solution_create(Session sess, Solution sln, Stream strm)
{
	/* create the makefile */
	const char* filename = make_get_solution_makefile(sess, sln);
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(sess, strm);
	return OKAY;
}
