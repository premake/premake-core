/**
 * \file   objects_internal.h
 * \brief  An internal API for inter-object data shuffling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

Solution project_get_solution(Project prj);
void     project_set_solution(Project prj, Solution sln);
void     solution_set_session(Solution sln, Session sess);
