/**
 * \file   actions.c
 * \brief  Built-in engine actions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include "premake.h"
#include "actions/actions.h"


SessionAction Actions[] = 
{
	{ "gmake",   "GNU Makefiles for POSIX, MinGW, and Cygwin",                gmake_action  },
	{ "vs2002",  "Microsoft Visual Studio 2002",                              vs2002_action },
	{ "vs2003",  "Microsoft Visual Studio 2003",                              vs2003_action },
	{ "vs2005",  "Microsoft Visual Studio 2005 (includes Express editions)",  vs2005_action },
	{ "vs2008",  "Microsoft Visual Studio 2008 (includes Express editions)",  vs2008_action },
	{ 0, 0, 0 }
};
