/**
 * \file   vs2003.c
 * \brief  Visual Studio 2003 project file generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x.h"
#include "vs200x_solution.h"


/** The VS2003 solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback SolutionCallbacks[] = 
{
	vs2002_solution_create,
	vs2003_solution_signature,
	vs2002_solution_projects,
	vs2003_solution_configuration,
	vs2002_solution_project_configuration,
	vs2002_solution_extensibility,
	NULL
};

/** The VS2003 project writing process, for session_enumerate_objects() */
static SessionProjectCallback ProjectCallbacks[] =
{
	NULL
};


/**
 * The Visual Studio 2003 action handler.
 * \param   sess   The active session object.
 * \returns OKAY if successful.
 */
int vs2003_action(Session sess)
{
	/* make sure I can support all of the features used in the session */
	if (vs200x_validate_session(sess) != OKAY)
	{
		return !OKAY;
	}

	stream_writeline(Console, "Generating project files for Visual Studio 2003...");
	return session_enumerate_objects(sess, SolutionCallbacks, ProjectCallbacks);
}
