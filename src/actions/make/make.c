/**
 * \file   make.c
 * \brief  Support functions for the makefile action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "make.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/error.h"
#include "base/path.h"


/**
 * Escapes spaces in a string value, so it can be safely written to the makefile.
 * \param   value      The string value to escape.
 * \returns The same string value, with spaces escaped.
 */
const char* make_escape(const char* value)
{
	char* buffer = buffers_next();

	const char* src = value;
	char* dst = buffer;
	while (*src != '\0')
	{
		if (*src == ' ')
		{
			*(dst++) = '\\';
		}
		*(dst++) = *(src++);
	}
	
	*dst = '\0';
	return buffer;
}


/**
 * Given a source file filename, returns the name of the corresponding .o file.
 * \param   filename   The source code filename.
 * \returns The filename of the .o file.
 */
const char* make_get_obj_filename(const char* filename)
{
	const char* basename = path_basename(filename);
	const char* obj_name = cstr_format("$(OBJDIR)/%s.o", basename);
	return obj_name;
}


/**
 * Get the name of the project makefile for a particular project.
 * If this project is the only object which will generate output to
 * its target location, then this function will return "Makefile" as
 * the filename. If any other object shares this output location, it
 * will return "ProjectName.make" instead, so that both objects may
 * coexist in the same directory.
 */
const char* make_get_project_makefile(Project prj)
{
	const char* my_path;
	int si, sn, in_conflict = 0;

	Session sess = project_get_session(prj);

	/* get the default filename for this project */
	my_path = project_get_filename(prj, "Makefile", "");

	/* see if any other solution wants to use this same path */
	sn = session_num_solutions(sess);
	for (si = 0; si < sn && !in_conflict; ++si)
	{
		const char* their_path;
		int pi, pn;

		Solution sln = session_get_solution(sess, si);
		their_path = solution_get_filename(sln, "Makefile", "");
		if (cstr_eq(my_path, their_path))
		{
			in_conflict = 1;
		}

		/* check any projects contained by this solution */
		pn = solution_num_projects(sln);
		for (pi = 0; pi < pn && !in_conflict; ++pi)
		{
			Project prj2 = solution_get_project(sln, pi);
			if (prj != prj2)
			{
				their_path = project_get_filename(prj2, "Makefile", "");
				if (cstr_eq(my_path, their_path))
				{
					in_conflict = 1;
				}
			}
		}
	}

	/* if a conflict was detected use an alternate name */
	if (in_conflict)
	{
		my_path = project_get_filename(prj, NULL, ".make");
	}

	/* all good */
	return my_path;
}


/**
 * Build a list of project names contained by the solution.
 * \param   sln    The solution to query.
 * \returns A list of project names. The caller owns this list and must destroy it when done.
 */
Strings make_get_project_names(Solution sln)
{
	Strings result;
	int i, n;

	result = strings_create();
	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		const char* name = project_get_name(prj);
		strings_add(result, name);
	}

	return result;
}


/**
 * Get the name of the solution makefile for a particular solution. 
 * If this solution is the only object which will generate output to
 * its target location, then this function will return "Makefile" as
 * the filename. If any other solution shares this output location, it
 * will return "SolutionName.make" instead, so that both objects may
 * coexist in the same directory.
 */
const char* make_get_solution_makefile(Solution sln)
{
	const char* my_path;
	int i, n;
	
	Session sess = solution_get_session(sln);

	/* get the default file name for this solution */
	my_path = solution_get_filename(sln, "Makefile", "");

	/* see if any other solution wants to use this same path */
	n = session_num_solutions(sess);
	for (i = 0; i < n; ++i)
	{
		Solution them = session_get_solution(sess, i);
		if (them != sln)
		{
			const char* their_path = solution_get_filename(them, "Makefile", "");
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


/**
 * Write a string value to a stream, escape any space characters it contains.
 * \param   strm       The output stream.
 * \param   value      The string value to escape.
 * \returns OKAY if successful.
 */
int make_write_escaped(Stream strm, const char* value)
{
	const char* escaped = make_escape(value);
	return stream_write(strm, escaped);
}
