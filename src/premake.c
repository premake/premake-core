/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "host/host.h"
#include "action/action.h"


/**
 * These are the steps in the process; each function runs one part of the whole.
 */
static HostExecutionStep Steps[] =
{
	host_parse_argv,        /* process the command line arguments */
	host_run_script,        /* run the main script (i.e. premake4.lua) */
	session_unload,         /* unload the objects built by the script into more accessible C data structures */
	host_show_help,         /* show help and version messages as appropriate; may end processing here */
	host_run_action,        /* run the action specified on the command line */
	NULL                    /* all done! */
};


/**
 * \brief   Program entry point.
 */
int main(int argc, const char** argv)
{
	Session sess;

	/* If testing is enabled, calling premake.exe with no arguments will
	 * trigger a call to the automated tests. This is used by a post-build
	 * step to run the tests after every successful build. */
#if defined(TESTING_ENABLED)
	if (argc == 1)
	{
		return host_tests();
	}
#else
    UNUSED(argc);
#endif

	/* initialize */
	host_set_argv(argv);
	sess = session_create();

	/* run */
	host_run_steps(sess, Steps);

	/* report back to the user and clean up */
	host_report_results(sess);
	session_destroy(sess);
	return OKAY;
}

