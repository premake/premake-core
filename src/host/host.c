/**
 * \file   host.c
 * \brief  Main executable API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "host/host.h"
#include "action/action.h"
#include "base/cstr.h"
#include "base/error.h"


/** argv, as passed into main(), stored here to be accessible to all host functions. */
static const char** Args = NULL;


/**
 * Display the results of the application run.
 * Any errors returned during the run will be written to stderr; otherwise, a
 * success message is written to stdout.
 * \param   sess   The current execution session.
 * \returns OKAY.
 */
int host_report_results(Session sess)
{
	const char* error = error_get();
	if (error)
	{
		stream_writeline(Console, "Error: %s", error);
	}

	sess = 0;  /* unused */
	return OKAY;
}


/**
 * Run the action specified by the user on the command line.
 * \param   sess   The execution session context.
 * \returns OKAY on success.
 */
int host_run_action(Session sess)
{
	const char* action;
	int i;

	assert(sess);

	/* identify the action */
	action = Args[0];

	for (i = 0; Actions[i].name != NULL; ++i)
	{
		if (cstr_eq(Actions[i].name, action))
		{
			return Actions[i].callback(sess);
		}
	}

	/* an invalid action was specified */
	error_set("invalid action '%s'", action);
	return !OKAY;
}


/**
 * Find and execute the project script file.
 * \param   sess   The session object.
 * \returns OKAY on success.
 */
int host_run_script(Session sess)
{
	int status;

	assert(sess);

	/* run the default file for now */
	session_run_file(sess, DEFAULT_SCRIPT_NAME);
	status = (error_get() == NULL) ? OKAY : !OKAY;
	return status;
}


/**
 * Run a list of steps, in order, checking status at each step.
 * \param   sess   The current session state.
 * \param   steps  A null-terminated list of step functions.
 * \returns OKAY on success.
 */
int host_run_steps(Session sess, HostExecutionStep* steps)
{
	int i, status;

	assert(sess);
	assert(steps);

	status = OKAY;
	for (i = 0; status == OKAY && steps[i] != NULL; ++i)
	{
		status = steps[i](sess);
	}

	return status;
}


/**
 * Remember the list of command-line parameters for subsequent calls 
 * to the other host functions later in the processing steps.
 * \param  argv   The argv variable is passed to main().
 */
void host_set_argv(const char** argv)
{
	/* skip over the progam name in argv[0] and just store the arguments */
	Args = &argv[1];
}


/**
 * Display help and version messages as appropriate. If any messages are
 * shown, execution of the main step loop will be stopped and the application
 * will exit (this seems to be the standard behavior of POSIX apps when
 * help is requested).
 * \param   sess    The current execution session context.
 * \returns OKAY is no help information was required, !OKAY to stop the loop.
 */
int host_show_help(Session sess)
{
	assert(Args);

	sess = 0;   /* unused */

	/* while (arg is option) { */
	/*    if (/version) ...    */
	/*    if (/help) ...       */

	/* if no action was specified give the user a clue */
	if (Args[0] == NULL)
	{
		stream_writeline(Console, HOST_SHORT_HELP);
		return !OKAY;
	}

	return OKAY;
}
