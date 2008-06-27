/**
 * \file   gmake_solution.c
 * \brief  GNU makefile solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "make.h"
#include "make_solution.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/path.h"
#include "base/strings.h"

const char* gmake_solution_project_rule(Session sess, Solution sln, Project prj);


/**
 * Write the GNU makefile all rule.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_all_rule(Session sess, Solution sln, Stream strm)
{
	Strings prj_names;
	int z;

	UNUSED(sess);
	assert(sln);
	assert(strm);

	prj_names = make_get_project_names(sln);
	z  = stream_writeline_strings(strm, prj_names, "all:", " ", "", "");
	z |= stream_writeline(strm, "");
	strings_destroy(prj_names);
	return z;
}


/**
 * Write the GNU solution makefile clean rules.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_clean_rule(Session sess, Solution sln, Stream strm)
{
	int i, n, z;

	assert(sess);
	assert(sln);
	assert(strm);

	z = stream_writeline(strm, "clean:");
	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		const char* rule = gmake_solution_project_rule(sess, sln, prj);
		z |= stream_writeline(strm, "%s clean", rule);
	}

	return z;
}


/**
 * Write makefile rules to set a default build configuration.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_default_config(Session sess, Solution sln, Stream strm)
{
	const char* default_config_name;
	int z;

	UNUSED(sess);
	assert(sln);
	assert(strm);

	default_config_name = solution_get_config(sln, 0);
	z  = stream_writeline(strm, "ifndef CONFIG");
	z |= stream_writeline(strm, "  CONFIG=%s", default_config_name);
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "export CONFIG");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the GNU makefile .PHONY rule.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_phony_rule(Session sess, Solution sln, Stream strm)
{
	Strings prj_names;
	int z;

	UNUSED(sess);
	assert(sln);
	assert(strm);

	prj_names = make_get_project_names(sln);
	z  = stream_writeline_strings(strm, prj_names, ".PHONY: all clean", " ", "", "");
	z |= stream_writeline(strm, "");
	strings_destroy(prj_names);
	return z;
}


/**
 * Build the makefile rule to call an individual project.
 * \param   sess  The current session context.
 * \param   sln   The solution containing the project.
 * \param   prj   The project to be built.
 * \returns The makefile rule to trigger the project build.
 */
const char* gmake_solution_project_rule(Session sess, Solution sln, Project prj)
{
	char* buffer = buffers_next();

	/* project file paths are specified relative to the solution */
	const char* sln_path = path_directory(solution_get_filename(sln, NULL, NULL));

	const char* prj_file = make_get_project_makefile(sess, prj);
	const char* prj_file_dir  = path_directory(prj_file);
	const char* prj_file_name = path_filename(prj_file);
	prj_file_dir = path_relative(sln_path, prj_file_dir);

	strcpy(buffer, "\t@$(MAKE)");
	if (!cstr_eq(".", prj_file_dir))
	{
		strcat(buffer, " --no-print-directory -C ");
		strcat(buffer, prj_file_dir);
	}
	if (!cstr_eq("Makefile", prj_file_name))
	{
		strcat(buffer, " -f ");
		strcat(buffer, prj_file_name);
	}

	return buffer;
}



/**
 * Write the GNU solution makefile project entry.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_projects(Session sess, Solution sln, Stream strm)
{
	int i, n, z = OKAY;

	assert(sess);
	assert(sln);
	assert(strm);

	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		const char* prj_name = project_get_name(prj);
		const char* rule = gmake_solution_project_rule(sess, sln, prj);

		z |= stream_writeline(strm, "%s:", prj_name);
		z |= stream_writeline(strm, "\t@echo ==== Building %s ====", prj_name);
		z |= stream_writeline(strm, rule);
		z |= stream_writeline(strm, "");
	}

	return z;
}


/**
 * Write the GNU makefile solution file signature block.
 * \param   sess    The execution session context.
 * \param   sln     The current solution.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int gmake_solution_signature(Session sess, Solution sln, Stream strm)
{
	Strings config_names;
	int z;

	UNUSED(sess);
	assert(sln);
	assert(strm);

	z  = stream_writeline(strm, "# GNU Makefile autogenerated by Premake");
	z |= stream_writeline(strm, "# Usage: make [ CONFIG=config_name ]");
	z |= stream_writeline(strm, "# Where {config_name} is one of:");

	config_names = solution_get_configs(sln);
	z |= stream_writeline_strings(strm, config_names, "#  ", " ", "", ",");
	z |= stream_writeline(strm, "");

	return z;
}
