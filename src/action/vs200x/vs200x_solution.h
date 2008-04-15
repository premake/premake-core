/**
 * \file   vs200x_solution.h
 * \brief  Visual Studio 200x solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_SOLUTION_H)
#define PREMAKE_VS200X_SOLUTION_H

#include "engine/session.h"

int         vs200x_solution_create(Session sess, Solution sln, Stream strm);
int         vs200x_solution_projects(Session sess, Solution sln, Stream strm);
int         vs200x_solution_signature(Session sess, Solution sln, Stream strm);
const char* vs200x_solution_tool_guid(const char* language);

#endif
