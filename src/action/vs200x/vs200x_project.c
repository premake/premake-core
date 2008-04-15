/**
 * \file   vs200x_project.c
 * \brief  Visual Studio 200x project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "vs200x_project.h"


/**
 * Returns the correct project file extension for a particular project definition.
 * \param   prj   The project to be identified.
 * \returns The project file extension for the given project.
 */
const char* vs200x_project_extension(Project prj)
{
	prj = 0;
	return ".vcproj";
}
