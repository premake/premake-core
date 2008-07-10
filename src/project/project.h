/**
 * \file   project.h
 * \brief  Project objects API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup project Project Objects
 *
 * Project objects: solutions, projects, and configurations.
 *
 * @{
 */
#if !defined(PREMAKE_PROJECT_H)
#define PREMAKE_PROJECT_H

#include "fields.h"
#include "blocks.h"
#include "filter.h"


/**
 * Project field index.
 * \note If you modify this list, you must also update ProjectFieldInfo[].
 */
enum ProjectField
{
	ProjectBaseDirectory,
	ProjectFiles,
	ProjectGuid,
	ProjectLanguage,
	ProjectLocation,
	ProjectName,
	NumProjectFields
};

extern struct FieldInfo ProjectFieldInfo[];


DECLARE_CLASS(Project)

Project     project_create(void);
void        project_destroy(Project prj);

const char* project_get_base_dir(Project prj);
Blocks      project_get_blocks(Project prj);
Strings     project_get_config_values(Project prj, enum BlockField field);
const char* project_get_configuration_filter(Project prj);
Fields      project_get_fields(Project prj);
const char* project_get_filename(Project prj, const char* basename, const char* ext);
Strings     project_get_files(Project prj);
const char* project_get_guid(Project prj);
const char* project_get_language(Project prj);
const char* project_get_location(Project prj);
const char* project_get_name(Project prj);
const char* project_get_outfile(Project prj);
const char* project_get_value(Project prj, enum ProjectField field);
int         project_is_valid_language(const char* language);
void        project_set_base_dir(Project prj, const char* base_dir);
void        project_set_filter(Project prj, Filter flt);
void        project_set_guid(Project prj, const char* guid);
void        project_set_language(Project prj, const char* language);
void        project_set_location(Project prj, const char* location);
void        project_set_name(Project prj, const char* name);
void        project_set_value(Project prj, enum ProjectField field, const char* value);
void        project_set_values(Project prj, enum ProjectField field, Strings values);
int         project_tests(void);

#endif
/** @} */
