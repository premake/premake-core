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
#include "vs200x_project.h"
#include "base/cstr.h"
#include "base/error.h"
#include "base/path.h"


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
 * Write out the list of projects contained by the solution.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs200x_solution_projects(Session sess, Solution sln, Stream strm)
{
	const char* sln_path;
	int i, n;
	sess = 0;  /* unused */

	/* project file paths are specified relative to the solution */
	sln_path = path_directory(solution_get_filename(sln, NULL, NULL));

	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		const char* prj_name  = project_get_name(prj);
		const char* prj_id    = project_get_guid(prj);
		const char* prj_ext   = vs200x_project_extension(prj);
		const char* prj_file  = project_get_filename(prj, prj_name, prj_ext);
		const char* tool_id   = vs200x_solution_tool_guid("c++");

		/* convert absolute project file name to be relative to solution */
		prj_file = path_relative(sln_path, prj_file);
		prj_file = path_translate(prj_file, "\\");

		stream_writeline(strm, "Project(\"{%s}\") = \"%s\", \"%s\", \"{%s}\"", tool_id, prj_name, prj_file, prj_id);
		stream_writeline(strm, "EndProject");
	}

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


/**
 * Returns the Visual Studio GUID for a particular project type.
 * \param   language   The programming language used in the project.
 * \returns The GUID corresponding the programming language.
 */
const char* vs200x_solution_tool_guid(const char* language)
{
	if (cstr_eq(language, "c") || cstr_eq(language, "c++"))
	{
		return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942";
	}
	else if (cstr_eq(language, "c#"))
	{
		return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC";
	}
	else
	{
		error_set("unsupported language '%s'", language); 
		return NULL;
	}
}
