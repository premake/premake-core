/**
 * \file   solution.h
 * \brief  The Solution class, representing the top-level container for projects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_SOLUTION_H)
#define PREMAKE_SOLUTION_H

#include "fields.h"
#include "project.h"


/**
 * Solution field index.
 * \note If you modify this list, you must also update SolutionFieldInfo[].
 */
enum SolutionField
{
	SolutionBaseDirectory,
	SolutionLocation,
	SolutionName,
	NumSolutionFields
};

extern struct FieldInfo SolutionFieldInfo[];


DECLARE_CLASS(Solution)

Solution    solution_create(void);
void        solution_destroy(Solution sln);

void        solution_add_config_name(Solution sln, const char* config_name);
void        solution_add_project(Solution sln, Project prj);
const char* solution_get_base_dir(Solution sln);
const char* solution_get_config_name(Solution sln, int index);
const char* solution_get_filename(Solution sln, const char* basename, const char* ext);
const char* solution_get_location(Solution sln);
const char* solution_get_name(Solution sln);
Project     solution_get_project(Solution sln, int index);
const char* solution_get_value(Solution sln, enum SolutionField field);
int         solution_num_configs(Solution sln);
int         solution_num_projects(Solution sln);
void        solution_set_base_dir(Solution sln, const char* base_dir);
void        solution_set_location(Solution sln, const char* location);
void        solution_set_name(Solution sln, const char* name);
void        solution_set_value(Solution sln, enum SolutionField field, const char* value);


#endif
