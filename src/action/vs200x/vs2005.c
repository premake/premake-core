/**
 * \file   vs2005.c
 * \brief  Visual Studio 2005 project file generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x_solution.h"


/** The VS2005 solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback Vs2005SolutionCallbacks[] = 
{
	vs200x_solution_create,
	vs200x_solution_signature,
	vs200x_solution_projects,
	NULL
};

/** The VS2005 project writing process, for session_enumerate_objects() */
static SessionProjectCallback Vs2005ProjectCallbacks[] =
{
	NULL
};


/**
 * The Visual Studio 2005 action handler.
 * \param   sess   The active session object.
 * \returns OKAY if successful.
 */
int vs2005_action(Session sess)
{
	stream_writeline(Console, "Generating project files for Visual Studio 2005...");
	return session_enumerate_objects(sess, Vs2005SolutionCallbacks, Vs2005ProjectCallbacks);
}

