/**
 * \file   vs2003.c
 * \brief  Visual Studio 2003 project file generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x_solution.h"


/** The VS2003 solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback Vs2003SolutionCallbacks[] = 
{
	vs200x_solution_create,
	NULL
};

/** The VS2003 project writing process, for session_enumerate_objects() */
static SessionProjectCallback Vs2003ProjectCallbacks[] =
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
	stream_writeline(Console, "Generating project files for Visual Studio 2003...");
	return session_enumerate_objects(sess, Vs2003SolutionCallbacks, Vs2003ProjectCallbacks);
}

