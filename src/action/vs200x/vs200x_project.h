/**
 * \file   vs200x_project.h
 * \brief  Visual Studio 200x project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_PROJECT_H)
#define PREMAKE_VS200X_PROJECT_H

#include "engine/session.h"

int vs2002_project_create(Session sess, Project prj, Stream strm);

#endif
