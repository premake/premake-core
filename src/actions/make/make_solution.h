/**
 * \file   make_solution.h
 * \brief  Makefile solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_SOLUTION_H)
#define PREMAKE_MAKE_SOLUTION_H

#include "objects/session.h"

int make_solution_clean_rule(Solution sln, Stream strm);
int make_solution_all_rule(Solution sln, Stream strm);
int make_solution_create(Solution sln, Stream strm);
int make_solution_default_config(Solution sln, Stream strm);
int make_solution_phony_rule(Solution sln, Stream strm);
int make_solution_projects(Solution sln, Stream strm);
int make_solution_signature(Solution sln, Stream strm);

#endif
