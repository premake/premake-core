/**
 * \file   vs2005_solution.c
 * \brief  Visual Studio 2005 solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x_solution.h"


/**
 * Write out the Visual Studio solution-level platform configuration block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2005_solution_platforms(Session sess, Solution sln, Stream strm)
{
	int i, n, z;
	UNUSED(sess);

	z  = stream_writeline(strm, "Global");
	z |= stream_writeline(strm, "\tGlobalSection(SolutionConfigurationPlatforms) = preSolution");

	n = solution_num_configs(sln);
	for (i = 0; i < n; ++i)
	{
		const char* config_name = solution_get_config(sln, i);
		z |= stream_writeline(strm, "\t\t%s|Win32 = %s|Win32", config_name, config_name);
	}

	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Write out the Visual Studio 2005 project-level platform configurations block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2005_solution_project_platforms(Session sess, Solution sln, Stream strm)
{
	int pi, pn, z;
	UNUSED(sess);
	z = stream_writeline(strm, "\tGlobalSection(ProjectConfigurationPlatforms) = postSolution");
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
			z |= stream_writeline(strm, "\t\t{%s}.%s|Win32.ActiveCfg = %s|Win32", prj_id, config_name, config_name);
			z |= stream_writeline(strm, "\t\t{%s}.%s|Win32.Build.0 = %s|Win32", prj_id, config_name, config_name);
		}
	}
	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Write out the Visual Studio 2005 solution properties block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2005_solution_properties(Session sess, Solution sln, Stream strm)
{
	int z;
	UNUSED(sess);
	UNUSED(sln);
	z  = stream_writeline(strm, "\tGlobalSection(SolutionProperties) = preSolution");
	z |= stream_writeline(strm, "\t\tHideSolutionNode = FALSE");
	z |= stream_writeline(strm, "\tEndGlobalSection");
	z |= stream_writeline(strm, "EndGlobal");
	return z;
}


/**
 * Write the Visual Studio 2005 solution file signature.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2005_solution_signature(Session sess, Solution sln, Stream strm)
{
	int z;
	UNUSED(sess);
	UNUSED(sln);
	stream_set_newline(strm, "\r\n");
	z  = stream_write_unicode_marker(strm);
	z |= stream_writeline(strm, "");
	z |= stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 9.00");
	z |= stream_writeline(strm, "# Visual Studio 2005");
	return z;
}
