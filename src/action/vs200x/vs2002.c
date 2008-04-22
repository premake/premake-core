/**
 * \file   vs2002.c
 * \brief  Visual Studio 2002 project file generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x_solution.h"


/** The VS2002 solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback SolutionCallbacks[] = 
{
	vs2002_solution_create,
	vs2002_solution_signature,
	vs2002_solution_projects,
	vs2002_solution_configuration,
	vs2002_solution_dependencies,
	vs2002_solution_project_configuration,
	vs2002_solution_extensibility,
	NULL
};

/** The VS2002 project writing process, for session_enumerate_objects() */
static SessionProjectCallback ProjectCallbacks[] =
{
	NULL
};


/**
 * The Visual Studio 2002 action handler.
 * \param   sess   The active session object.
 * \returns OKAY if successful.
 */
int vs2002_action(Session sess)
{
	stream_writeline(Console, "Generating project files for Visual Studio 2002...");
	return session_enumerate_objects(sess, SolutionCallbacks, ProjectCallbacks);
}

