/**
 * \file   make.h
 * \brief  Support functions for the makefile action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_H)
#define PREMAKE_MAKE_H

#include "session/session.h"

const char* make_get_obj_filename(const char* filename);
const char* make_get_project_makefile(Session sess, Project prj);
Strings     make_get_project_names(Solution sln);
const char* make_get_solution_makefile(Session sess, Solution sln);

#endif
