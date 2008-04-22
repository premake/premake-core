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
 * Get the name of the project makefile for a particular project.
 * \param   sess   The current execution session context.
 * \param   prj    The project being requested.
 * \returns If this project is the only object which will generate output to
 *          its target location, then this function will return "Makefile" as
 *          the filename. If any other object shares this output location, it
 *          will return "ProjectName.make" instead, so that both objects may
 *          coexist in the same directory.
 */
const char* make_get_project_makefile(Session sess, Project prj)
{
	const char* my_path;
	const char* their_path;
	int si, sn;

	assert(sess);
	assert(prj);

	/* get the full makefile path for this project */
	my_path = project_get_filename(prj, "Makefile", NULL);

	/* see if any other solution wants to use this same path */
	sn = session_num_solutions(sess);
	for (si = 0; si < sn; ++si)
	{
		int pi, pn;

		Solution sln2 = session_get_solution(sess, si);
		their_path = solution_get_filename(sln2, "Makefile", NULL);
		if (cstr_eq(my_path, their_path))
		{
			/* conflict; use the alternate name */
			my_path = project_get_filename(prj, NULL, ".make");
			return my_path;
		}

		/* check any projects contained by this solution */
		pn = solution_num_projects(sln2);
		for (pi = 0; pi < pn; ++pi)
		{
			Project prj2 = solution_get_project(sln2, pi);
			if (prj != prj2)
			{
				their_path = project_get_filename(prj2, "Makefile", NULL);
				if (cstr_eq(my_path, their_path))
				{
					/* conflict; use the alternate name */
					my_path = project_get_filename(prj, NULL, ".make");
					return my_path;
				}
			}
		}
	}

	/* all good */
	return my_path;
}


/**
 * Get the name of the solution makefile for a particular solution. 
 * \param   sess   The current execution session context.
 * \param   sln    The solution being requested.
 * \returns If this solution is the only object which will generate output to
 *          its target location, then this function will return "Makefile" as
 *          the filename. If any other solution shares this output location, it
 *          will return "SolutionName.make" instead, so that both objects may
 *          coexist in the same directory.
 */
const char* make_get_solution_makefile(Session sess, Solution sln)
{
	const char* my_path;
	const char* their_path;
	int i, n;

	assert(sess);
	assert(sln);

	/* get the full makefile path for this solution */
	my_path = solution_get_filename(sln, "Makefile", NULL);

	/* see if any other solution wants to use this same path */
	n = session_num_solutions(sess);
	for (i = 0; i < n; ++i)
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
