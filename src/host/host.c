/**
 * \file   host.c
 * \brief  Main executable API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "host/host.h"
#include "script/script.h"
#include "actions/actions.h"
#include "base/cstr.h"
#include "base/env.h"
#include "base/error.h"
#include "base/file.h"


DEFINE_CLASS(Host)
{
	Script script;
	const char** args;
};


/**
 * Create a new Premake host object.
 * \returns A new session object, or NULL if the scripting engine fails to start.
 */
Host host_create()
{
	Host host;

	Script script = script_create();
	if (script == NULL)
	{
		return NULL;
	}

	host = ALLOC_CLASS(Host);
	host->script = script;
	host->args = NULL;
	return host;
}


/**
 * Destroy a Premake host object and release the associated memory.
 */
void host_destroy(Host host)
{
	assert(host);
	script_destroy(host->script);
	free(host);
}


/**
 * Initial processing and validation of the command line arguments.
 * \returns OKAY on success.
 */
int host_parse_argv(Host host)
{
	script_set_action(host->script, host->args[0]);
	env_set_action(host->args[0]);
	return OKAY;
}


/**
 * Display the results of the application run.
 * Any errors returned during the run will be written to stderr; otherwise, a
 * success message is written to stdout.
 */
int host_report_results()
{
	const char* error = error_get();
	if (error)
	{
		stream_writeline(Console, "Error: %s", error);
	}
	return OKAY;
}


/**
 * Run the action specified by the user on the command line.
 * \returns OKAY on success.
 */
int host_run_action(Host host)
{
	Session sess;
	const char* action;
	int i, z = OKAY;

	assert(host);

	/* there must be a project file defined or I can go no further */
	if (!file_exists(DEFAULT_SCRIPT_NAME))
	{
		error_set("script file '%s' not found", DEFAULT_SCRIPT_NAME);
		return !OKAY;
	}

	/* unload the defined objects from the script */
	sess = script_unload(host->script);
	if (sess == NULL)
	{
		return !OKAY;
	}

	/* find the action in the master list and execute the associated callback */
	action = host->args[0];
	for (i = 0; Actions[i].name != NULL; ++i)
	{
		if (cstr_eq(Actions[i].name, action))
		{
			z = Actions[i].callback(sess);
			session_destroy(sess);
			return z;
		}
	}

	/* an invalid action was specified */
	error_set("invalid action '%s'", action);
	return !OKAY;
}


/**
 * Find and execute the project script file.
 * \returns OKAY on success.
 */
int host_run_script(Host host)
{
	assert(host);

	/* run the default file for now. If the script file doesn't exist let execution
	 * continue so I can display help, etc. */
	if (file_exists(DEFAULT_SCRIPT_NAME))
	{
		script_run_file(host->script, DEFAULT_SCRIPT_NAME);
		return (error_get() == NULL) ? OKAY : !OKAY;
	}
	else
	{
	    return OKAY;
	}
}


/**
 * Remember the list of command-line parameters for subsequent calls 
 * to the other host functions later in the processing steps.
 */
void host_set_argv(Host host, const char** argv)
{
	/* skip over the progam name in argv[0] and just store the arguments */
	host->args = &argv[1];
}


/**
 * Display help and version messages as appropriate. If any messages are
 * shown, execution of the main step loop will be stopped and the application
 * will exit (this seems to be the standard behavior of POSIX apps when
 * help is requested).
 * \returns OKAY is no help information was required, !OKAY to stop the loop.
 */
int host_show_help(Host host)
{
	/* while (arg is option) { */
	/*    if (/version) ...    */
	/*    if (/help) ...       */

	/* if no action was specified give the user a clue */
	if (host->args[0] == NULL)
	{
		stream_writeline(Console, HOST_SHORT_HELP);
		return !OKAY;
	}

	return OKAY;
}
