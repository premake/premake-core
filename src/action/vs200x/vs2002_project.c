/**
 * \file   vs2002_project.c
 * \brief  Visual Studio 2002 project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "vs200x_project.h"


/**
 * Create a new output stream for a project, and make it active for subsequent writes.
 * \param   sess    The execution session context.
 * \param   prj     The current project.
 * \param   strm    The currently active stream; set with session_set_active_stream().
 * \returns OKAY if successful.
 */
int vs2002_project_create(Session sess, Project prj, Stream strm)
{
	/* create the project file */
	const char* extension = vs200x_project_file_extension(prj);
	const char* filename  = project_get_filename(prj, NULL, extension);
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(sess, strm);
	return OKAY;
}
