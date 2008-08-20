/**
 * \file   solution.h
 * \brief  The Solution class, representing the top-level container for projects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup solution Solution
 * \ingroup  objects
 *
 * @{
 */
#if !defined(PREMAKE_SOLUTION_H)
#define PREMAKE_SOLUTION_H

DECLARE_CLASS(Solution)

#include "fields.h"
#include "project.h"
#include "blocks.h"
#include "base/strings.h"


/**
 * Solution field index.
 * \note If you modify this list, you must also update SolutionFieldInfo[].
 */
typedef enum enum_SolutionField
{
	SolutionBaseDir,
	SolutionConfigurations,
	SolutionKind,
	SolutionLanguage,
	SolutionLocation,
	SolutionName,
	NumSolutionFields
} SolutionField;

extern FieldInfo SolutionFieldInfo[];


Solution    solution_create(void);
void        solution_destroy(Solution sln);

void        solution_add_config(Solution sln, const char* config_name);
void        solution_add_project(Solution sln, Project prj);
const char* solution_get_base_dir(Solution sln);
Blocks      solution_get_blocks(Solution sln);
const char* solution_get_config(Solution sln, int index);
Strings     solution_get_configs(Solution sln);
Fields      solution_get_fields(Solution sln);
const char* solution_get_filename(Solution sln, const char* basename, const char* ext);
const char* solution_get_kind(Solution sln);
const char* solution_get_language(Solution sln);
const char* solution_get_location(Solution sln);
const char* solution_get_name(Solution sln);
Project     solution_get_project(Solution sln, int index);
Session     solution_get_session(Solution sln);
const char* solution_get_value(Solution sln, SolutionField field);
int         solution_num_configs(Solution sln);
int         solution_num_projects(Solution sln);
void        solution_set_base_dir(Solution sln, const char* base_dir);
void        solution_set_kind(Solution sln, const char* kind);
void        solution_set_language(Solution sln, const char* language);
void        solution_set_location(Solution sln, const char* location);
void        solution_set_name(Solution sln, const char* name);
void        solution_set_value(Solution sln, SolutionField field, const char* value);


#endif
/** @} */
