/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "host/host.h"
#include "actions/actions.h"


/**
 * \brief   Program entry point.
 */
int main(int argc, const char** argv)
{
	Host host;
	int z = OKAY;

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
	host = host_create();
	host_set_argv(host, argv);

	/* run */
	if (z == OKAY)  z = host_parse_argv(host);
	if (z == OKAY)  z = host_run_script(host);
	if (z == OKAY)  z = host_show_help(host);
	if (z == OKAY)  z = host_run_action(host);

	/* report back to the user and clean up */
	host_report_results();
	host_destroy(host);
	return z;
}

