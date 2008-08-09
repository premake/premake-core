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

#include "objects/session.h"

DECLARE_CLASS(Host)


/**
 * The short help message, displayed if Premake is run with no arguments.
 */
#define HOST_SHORT_HELP  "Type 'premake --help' for help."


Host host_create();
void host_destroy(Host host);

int  host_parse_argv(Host host);
int  host_report_results(void);
int  host_run_action(Host host);
int  host_run_script(Host host);
void host_set_argv(Host host, const char** argv);
int  host_show_help(Host host);
int  host_tests(void);

#endif
/** @} */
