/**
 * \file   gmake.c
 * \brief  GNU makefile generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "actions/actions.h"
#include "make.h"
#include "make_solution.h"
#include "make_project.h"


/** The project features supported by this action */
static SessionFeatures Features =
{
	{ "c", "c++", NULL },
};


/** The GNU make solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback SolutionCallbacks[] = 
{
	make_solution_create,
	make_solution_signature,
	make_solution_default_config,
	make_solution_phony_rule,
	make_solution_all_rule,
	make_solution_projects,
	make_solution_clean_rule,
	NULL
};

/** The GNU make project writing process, for session_enumerate_objects() */
static SessionProjectCallback ProjectCallbacks[] =
{
	make_project_create,
	make_project_signature,
	session_enumerate_configurations,
	make_project_objects,
	make_project_resources,
	gmake_project_shell_detect,
	make_project_phony_rule,
	make_project_target,
	make_project_mkdir_rules,
	make_project_clean_rules,
	make_project_source_rules,
	make_project_include_dependencies,
	NULL
};


/** The GNU make configuration writing process, for session_enumerate_configurations() */
static SessionProjectCallback ConfigCallbacks[] =
{
	make_project_config_conditional,
	make_project_config_outdir,
	make_project_config_outfile,
	make_project_config_objdir,
	make_project_config_cppflags,
	make_project_config_cflags,
	make_project_config_cxxflags,
	make_project_config_ldflags,
	make_project_config_lddeps,
	make_project_config_resflags,
	make_project_config_end,
	NULL
};


/**
 * The GNU make action handler.
 * \param   sess   The active session object.
 * \returns OKAY if successful.
 */
int gmake_action(Session sess)
{
	/* make sure I can support all of the features used in the session */
	if (session_validate(sess, &Features) != OKAY)
	{
		return !OKAY;
	}

	stream_writeline(Console, "Generating project files for GNU make...");
	return session_enumerate_objects(sess, SolutionCallbacks, ProjectCallbacks, ConfigCallbacks);
}

