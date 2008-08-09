/**
 * \file   vs200x_solution.h
 * \brief  Visual Studio 200x solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_SOLUTION_H)
#define PREMAKE_VS200X_SOLUTION_H

#include "objects/solution.h"

int vs2002_solution_configuration(Solution sln, Stream strm);
int vs2002_solution_dependencies(Solution sln, Stream strm);
int vs2002_solution_extensibility(Solution sln, Stream strm);
int vs2002_solution_project_configuration(Solution sln, Stream strm);
int vs2002_solution_projects(Solution sln, Stream strm);
int vs2002_solution_signature(Solution sln, Stream strm);

int vs2003_solution_configuration(Solution sln, Stream strm);
int vs2003_solution_signature(Solution sln, Stream strm);

int vs2005_solution_platforms(Solution sln, Stream strm);
int vs2005_solution_project_platforms(Solution sln, Stream strm);
int vs2005_solution_properties(Solution sln, Stream strm);
int vs2005_solution_signature(Solution sln, Stream strm);

int vs2008_solution_signature(Solution sln, Stream strm);

int vs200x_solution_create(Solution sln, Stream strm);

#endif
