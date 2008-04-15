/**
 * \file   make.c
 * \brief  Support functions for the makefile action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "action/make/make.h"
#include "base/cstr.h"


/**
 * Get the name of the solution makefile for a particular solution. 
 * \param   sess   The current execution session context.
 * \param   sln    The solution being requested.
 * \returns If this solution is the only object which will generate output to
 *          its target location, then this function will return "Makefile". 
 *          If another solution shares this output location, it will return
 *          "{Solution name}.make" instead, so that both solution makefiles
 *          may live in the same directory.
 */
const char* make_get_solution_makefile(Session sess, Solution sln)
{
	const char* my_path;
	const char* their_path;
	int i;

	assert(sess);
	assert(sln);

	/* get the full makefile path for this solution */
	my_path = solution_get_filename(sln, "Makefile", NULL);

	/* see if any other solution wants to use this same path */
	for (i = 0; i < session_num_solutions(sess); ++i)
	{
		Solution them = session_get_solution(sess, i);
		if (them != sln)
		{
			their_path = solution_get_filename(them, "Makefile", NULL);
			if (cstr_eq(my_path, their_path))
			{
				/* conflict; use the alternate name */
				my_path = solution_get_filename(sln, NULL, ".make");
				return my_path;
			}
		}
	}

	/* all good */
	return my_path;
}
