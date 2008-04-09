/**
 * \file   make_solution.h
 * \brief  Makefile solution generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_SOLUTION_H)
#define PREMAKE_MAKE_SOLUTION_H

#include "engine/session.h"

int make_solution_create(Session sess, Solution sln, Stream strm);
int make_solution_signature(Session sess, Solution sln, Stream strm);

#endif
