/**
 * \file   host.h
 * \brief  Main executable API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup host Host
 *
 * The "host" part of the application, which is responsible for parsing the command
 * line arguments, and the overall flow of the application. 
 *
 * @{
 */
#if !defined(PREMAKE_HOST_H)
#define PREMAKE_HOST_H

#include "session/session.h"

/**
 * The short help message, displayed if Premake is run with no arguments.
 */
#define HOST_SHORT_HELP  "Type 'premake --help' for help."


/**
 * Abstract out one step in the process, so I can treat them all identically.
 * This lets me unit test the higher-level logic.
 * \param   sess  The current session state.
 * \returns OKAY if successful.
 */
typedef int (*HostExecutionStep)(Session sess);


int  host_parse_argv(Session sess);
int  host_report_results(Session sess);
int  host_run_action(Session sess);
int  host_run_script(Session sess);
int  host_run_steps(Session sess, HostExecutionStep* steps);
void host_set_argv(const char** argv);
int  host_show_help(Session sess);
int  host_tests(void);

#endif
/** @} */
