/**
 * \file   make.h
 * \brief  Support functions for the makefile action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_H)
#define PREMAKE_MAKE_H

#include "objects/project.h"

const char* make_escape(const char* value);
const char* make_get_obj_filename(const char* filename);
const char* make_get_project_makefile(Project prj);
Strings     make_get_project_names(Solution sln);
const char* make_get_solution_makefile(Solution sln);
int         make_write_escaped(Stream strm, const char* value);

#endif
