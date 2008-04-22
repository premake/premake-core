/**
 * \file   make_solution.h
 * \brief  Makefile solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_SOLUTION_H)
#define PREMAKE_MAKE_SOLUTION_H

#include "engine/session.h"

int make_solution_create(Session sess, Solution sln, Stream strm);

int gmake_solution_all_rule(Session sess, Solution sln, Stream strm);
int gmake_solution_clean_rule(Session sess, Solution sln, Stream strm);
int gmake_solution_default_config(Session sess, Solution sln, Stream strm);
int gmake_solution_phony_rule(Session sess, Solution sln, Stream strm);
int gmake_solution_projects(Session sess, Solution sln, Stream strm);
int gmake_solution_signature(Session sess, Solution sln, Stream strm);

#endif
