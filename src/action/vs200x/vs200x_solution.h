/**
 * \file   vs200x_solution.h
 * \brief  Visual Studio 200x solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_SOLUTION_H)
#define PREMAKE_VS200X_SOLUTION_H

#include "session/session.h"

int vs2002_solution_configuration(Session sess, Solution sln, Stream strm);
int vs2002_solution_dependencies(Session sess, Solution sln, Stream strm);
int vs2002_solution_extensibility(Session sess, Solution sln, Stream strm);
int vs2002_solution_project_configuration(Session sess, Solution sln, Stream strm);
int vs2002_solution_projects(Session sess, Solution sln, Stream strm);
int vs2002_solution_signature(Session sess, Solution sln, Stream strm);

int vs2003_solution_configuration(Session sess, Solution sln, Stream strm);
int vs2003_solution_signature(Session sess, Solution sln, Stream strm);

int vs2005_solution_platforms(Session sess, Solution sln, Stream strm);
int vs2005_solution_project_platforms(Session sess, Solution sln, Stream strm);
int vs2005_solution_properties(Session sess, Solution sln, Stream strm);
int vs2005_solution_signature(Session sess, Solution sln, Stream strm);

int vs2008_solution_signature(Session sess, Solution sln, Stream strm);

int vs200x_solution_create(Session sess, Solution sln, Stream strm);

#endif
