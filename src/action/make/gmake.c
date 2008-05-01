/**
 * \file   gmake.c
 * \brief  GNU makefile generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "make.h"
#include "make_solution.h"


/** The GNU make solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback SolutionCallbacks[] = 
{
	make_solution_create,
	gmake_solution_signature,
	gmake_solution_default_config,
	gmake_solution_phony_rule,
	gmake_solution_all_rule,
	gmake_solution_projects,
	gmake_solution_clean_rule,
	NULL
};

/** The GNU make project writing process, for session_enumerate_objects() */
static SessionProjectCallback ProjectCallbacks[] =
{
	NULL
};


/** The GNU make configuration writing process, for session_enumerate_configurations() */
static SessionProjectCallback ConfigCallbacks[] =
{
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
	if (make_validate_session(sess) != OKAY)
	{
		return !OKAY;
	}

	stream_writeline(Console, "Generating project files for GNU make...");
	return session_enumerate_objects(sess, SolutionCallbacks, ProjectCallbacks, ConfigCallbacks);
}

