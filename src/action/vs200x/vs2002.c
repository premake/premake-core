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
static SessionSolutionCallback Vs2002SolutionCallbacks[] = 
{
	vs200x_solution_create,
	NULL
};

/** The VS2002 project writing process, for session_enumerate_objects() */
static SessionProjectCallback Vs2002ProjectCallbacks[] =
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
	return session_enumerate_objects(sess, Vs2002SolutionCallbacks, Vs2002ProjectCallbacks);
}

