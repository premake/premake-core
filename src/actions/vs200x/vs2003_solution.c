/**
 * \file   vs2003_solution.c
 * \brief  Visual Studio 2003 solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x_solution.h"


/**
 * Create the Visual Studio 2003 solution configuration block.
 */
int vs2003_solution_configuration(Solution sln, Stream strm)
{
	int i, n, z;

	z  = stream_writeline(strm, "Global");
	z |= stream_writeline(strm, "\tGlobalSection(SolutionConfiguration) = preSolution");

	n = solution_num_configs(sln);
	for (i = 0; i < n; ++i)
	{
		const char* config_name = solution_get_config(sln, i);
		z |= stream_writeline(strm, "\t\t%s = %s", config_name, config_name);
	}

	z |= stream_writeline(strm, "\tEndGlobalSection");
	return z;
}


/**
 * Write the Visual Studio 2003 solution file signature.
 */
int vs2003_solution_signature(Solution sln, Stream strm)
{
	int z;
	UNUSED(sln);
	stream_set_newline(strm, "\r\n");
	z = stream_writeline(strm, "Microsoft Visual Studio Solution File, Format Version 8.00");
	return z;
}
