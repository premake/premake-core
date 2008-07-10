/**
 * \file   vs2002_solution.c
 * \brief  Visual Studio 2002 solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "vs200x_solution.h"
#include "vs200x_project.h"
#include "base/path.h"


/**
 * Create the Visual Studio 2002 solution configuration block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_configuration(Session sess, Solution sln, Stream strm)
{
	int i, n, z;
	UNUSED(sess);

	z  = stream_writeline(strm, "Global");
	z |= stream_writeline(strm, "\tGlobalSection(SolutionConfiguration) = preSolution");
	
	n = solution_num_configs(sln);
	for (i = 0; i < n; ++i)
	{
		const char* config_name = solution_get_config(sln, i);
		z |= stream_writeline(strm, "\t\tConfigName.%d = %s", i, config_name);
	}

	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Create the Visual Studio 2002 project dependencies block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_dependencies(Session sess, Solution sln, Stream strm)
{
	int z;
	UNUSED(sess);
	UNUSED(sln);
	z  = stream_writeline(strm, "\tGlobalSection(ProjectDependencies) = postSolution");
	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Write out the Visual Studio 2002 solution extensibility block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_extensibility(Session sess, Solution sln, Stream strm)
{
	int z;
	UNUSED(sess);
	UNUSED(sln);
	z  = stream_writeline(strm, "\tGlobalSection(ExtensibilityGlobals) = postSolution");
	z |= stream_writeline(strm, "\tEndGlobalSection");
	z |= stream_writeline(strm, "\tGlobalSection(ExtensibilityAddIns) = postSolution");
	z |= stream_writeline(strm, "\tEndGlobalSection");
	z |= stream_writeline(strm, "EndGlobal");
	return z;
}


/**
 * Write out the Visual Studio 2002 project configurations block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_project_configuration(Session sess, Solution sln, Stream strm)
{
	int pi, pn, z;
	UNUSED(sess);
	z  = stream_writeline(strm, "\tGlobalSection(ProjectConfiguration) = postSolution");
	pn = solution_num_projects(sln);
	for (pi = 0; pi < pn; ++pi)
	{
		int ci, cn;
		Project prj = solution_get_project(sln, pi);
		const char* prj_id = project_get_guid(prj);

		cn = solution_num_configs(sln);
		for (ci = 0; ci < cn; ++ci)
		{
			const char* config_name = solution_get_config(sln, ci);
			z |= stream_writeline(strm, "\t\t{%s}.%s.ActiveCfg = %s|Win32", prj_id, config_name, config_name);
			z |= stream_writeline(strm, "\t\t{%s}.%s.Build.0 = %s|Win32", prj_id, config_name, config_name);
		}
	}
	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Write out the list of projects contained by the solution.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_projects(Session sess, Solution sln, Stream strm)
{
	const char* sln_path;
	int i, n, z = OKAY;

	UNUSED(sess);

	/* project file paths are specified relative to the solution */
	sln_path = path_directory(solution_get_filename(sln, NULL, NULL));

	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		const char* prj_name  = project_get_name(prj);
		const char* prj_id    = project_get_guid(prj);
		const char* prj_lang  = project_get_language(prj);
		const char* prj_ext   = vs200x_project_file_extension(prj);
		const char* prj_file  = project_get_filename(prj, prj_name, prj_ext);
		const char* tool_id   = vs200x_tool_guid(prj_lang);

		/* convert absolute project file name to be relative to solution */
		prj_file = path_relative(sln_path, prj_file);
		prj_file = path_translate(prj_file, "\\");

		z |= stream_writeline(strm, "Project(\"{%s}\") = \"%s\", \"%s\", \"{%s}\"", tool_id, prj_name, prj_file, prj_id);
		z |= stream_writeline(strm, "EndProject");
	}

	return z;
}


/**
 * Write the Visual Studio 2002 solution file signature.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_solution_signature(Session sess, Solution sln, Stream strm)
{
	int z;
	UNUSED(sess);
	UNUSED(sln);
	stream_set_newline(strm, "\r\n");
	z = stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 7.00");
	return z;
}
