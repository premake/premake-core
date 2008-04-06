/**
 * \file   gmake.c
 * \brief  GNU makefile generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "make_solution.h"


/** The GNU make solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback GmakeSolutionCallbacks[] = 
{
	make_solution_create,
	NULL
};

/** The GNU make project writing process, for session_enumerate_objects() */
static SessionProjectCallback GmakeProjectCallbacks[] =
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
	stream_writeline(Console, "Generating project files for GNU make...");
	return session_enumerate_objects(sess, GmakeSolutionCallbacks, GmakeProjectCallbacks);
}

