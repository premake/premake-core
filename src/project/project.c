/**
 * \file   project.c
 * \brief  The project class.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "project/project.h"
#include "project/solution.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/guid.h"
#include "base/path.h"
#include "base/strings.h"
#include "platform/platform.h"


struct FieldInfo ProjectFieldInfo[] =
{
	{ "basedir",    StringField,  NULL            },
	{ "files",      FilesField,   NULL            },
	{ "guid",       StringField,  guid_is_valid   },
	{ "language",   StringField,  NULL            },
	{ "location",   StringField,  NULL            },
	{ "name",       StringField,  NULL            },
	{  0,           0,            NULL            }
};


DEFINE_CLASS(Project)
{
	Solution solution;
	Fields fields;
	const char* config_filter;
};


/**
 * Create and initialize a new project object.
 * \returns A new project object.
 */
Project project_create()
{
	Project prj = ALLOC_CLASS(Project);
	prj->solution = NULL;
	prj->fields = fields_create(ProjectFieldInfo);
	prj->config_filter = NULL;
	return prj;
}


/**
 * Destroy a project object and release the associated memory.
 * \param   prj   The project object to destroy.
 */
void project_destroy(Project prj)
{
	assert(prj);
	fields_destroy(prj->fields);
	free(prj);
}


/**
 * Get the base directory for the project; any properties containing relative
 * paths are relative to this location.
 * \param   prj     The project object to query.
 * \returns The base directory, or NULL if no directory has been set.
 */
const char* project_get_base_dir(Project prj)
{
	return project_get_value(prj, ProjectBaseDirectory);
}


/**
 * Retrieve the current configuration filter. All subsequent requests for configuration
 * values will return settings from this configuration only.
 * \param   prj      The project object to query.
 * \returns The current configuration filter, or NULL if no filter has been set.
 */
const char* project_get_configuration_filter(Project prj)
{
	assert(prj);
	return prj->config_filter;
}


/**
 * Retrieve the fields object for this solution; used to unload values from the script.
 */
Fields project_get_fields(Project prj)
{
	assert(prj);
	return prj->fields;
}


/**
 * Get the path to the project output file, using the provided file extension.
 * \param   prj      The project object to query.
 * \param   basename The base filename; if NULL the project name will be used.
 * \param   ext      The file extension to be used on the filename; may be NULL.
 * \returns The path to the project file.
 */
const char* project_get_filename(Project prj, const char* basename, const char* ext)
{
	const char* base_dir;
	const char* location;
	const char* directory;
	const char* result;

	assert(prj);

	if (!basename)
	{
		basename = project_get_name(prj);
	}


	if (!ext)
	{
		ext = "";
	}

	base_dir = project_get_base_dir(prj);
	location = project_get_location(prj);
	directory = path_join(base_dir, location);

	result = path_assemble(directory, basename, ext);
	return result;
}


/**
 * Retrieve the list of source files associated with a project.
 */
Strings project_get_files(Project prj)
{
	assert(prj);
	return fields_get_values(prj->fields, ProjectFiles);
}


/**
 * Retrieve the GUID associated with a project.
 */
const char* project_get_guid(Project prj)
{
	assert(prj);
	return project_get_value(prj, ProjectGuid);
}


/**
 * Get the programming language used by the project.
 * \param   prj     The project object to query.
 * \returns The language used by the project, or NULL if no language has been set.
 */
const char* project_get_language(Project prj)
{
	const char* result = project_get_value(prj, ProjectLanguage);
	if (result == NULL && prj->solution != NULL)
	{
		result = solution_get_language(prj->solution);
	}
	return result;
}


/**
 * Retrieve the output location (the relative path from the base directory to the
 * target output directory) for this project.
 * \param   prj    The project object to modify.
 * \returns The project output location, or NULL if no location has been set.
 */
const char* project_get_location(Project prj)
{
	return project_get_value(prj, ProjectLocation);
}


/**
 * Get the name of the project.
 * \returns The name, if set, NULL otherwise.
 */
const char* project_get_name(Project prj)
{
	return project_get_value(prj, ProjectName);
}


/**
 * Retrieve the output filename for this project, taking into account platform-specific
 * naming conventions. For instance, for a project named "MyProject" this function would
 * return "MyProject.exe" on Windows. No path information is included, use the function
 * project_get_outdir() for that.
 */
const char* project_get_outfile(Project prj)
{
	char* buffer = buffers_next();
	strcpy(buffer, project_get_name(prj));
	if (platform_get() == Windows)
	{
		strcat(buffer, ".exe");
	}
	return buffer;
}


/**
 * Retrieve the solution associated with this project (internal).
 * \param   prj      The project to query.
 * \returns The associated solution, or NULL if no association has been made.
 */
Solution project_get_solution(Project prj)
{
	return prj->solution;
}


/**
 * Retrieve a string (single value) fields from a project, using the field indices.
 * \param   prj      The project object to query.
 * \param   field    The index of the field to query.
 * \returns The value of the field if set, of NULL.
 */
const char* project_get_value(Project prj, enum ProjectField field)
{
	assert(prj);
	return fields_get_value(prj->fields, field);
}


/**
 * Returns true if the specified language is recognized. Current valid language strings
 * are 'c', 'c++', and 'c#'.
 * \param   language   The language string.
 * \returns True if the language string is recognized.
 */
int project_is_valid_language(const char* language)
{
	return (cstr_eq(language, "c") ||
	        cstr_eq(language, "c++") ||
			cstr_eq(language, "c#"));
}


/**
 * Set the base directory of the project.
 * \param   prj      The project object to modify.
 * \param   base_dir The new base directory.
 */
void project_set_base_dir(Project prj, const char* base_dir)
{
	project_set_value(prj, ProjectBaseDirectory, base_dir);
}


/**
 * Set the current configuration filter. All subsequent requests for configuration
 * values will return settings from this configuration only.
 * \param   prj      The project object to query.
 * \param   cfg_name The name of the configuration on which to filter.
 */
void project_set_configuration_filter(Project prj, const char* cfg_name)
{
	assert(prj);
	prj->config_filter = cfg_name;
}


/**
 * Set the GUID associated with a project. The GUID is required by the Visual
 * Studio generators, and must be unique per project.
 * \param   prj        The project to modify.
 * \param   guid       The new project GUID.
 */
void project_set_guid(Project prj, const char* guid)
{
	project_set_value(prj, ProjectGuid, guid);
}


/**
 * Set the programming language used by a project.
 * \param   prj        The project to modify.
 * \param   language   The programming language used by the project.
 */
void project_set_language(Project prj, const char* language)
{
	project_set_value(prj, ProjectLanguage, language);
}


/**
 * Set the output location (the relative path from the base directory to the
 * target output directory) for this project.
 * \param   prj        The project object to modify.
 * \param   location   The new output location.
 */
void project_set_location(Project prj, const char* location)
{
	project_set_value(prj, ProjectLocation, location);
}


/**
 * Set the name of the project.
 * \param prj    The project object.
 * \param name   The new for the project.
 */
void project_set_name(Project prj, const char* name)
{
	project_set_value(prj, ProjectName, name);
}


/**
 * Associate a solution with this project (internal).
 * \param   prj      The project to modify.
 * \param   sln      The solution to associate with this project.
 */
void project_set_solution(Project prj, Solution sln)
{
	assert(prj);
	prj->solution = sln;
}


/**
 * Set a string (single value) field on a project, using the field indices.
 * \param   prj      The project object.
 * \param   field    The field to set.
 * \param   value    The new value for the field.
 */
void project_set_value(Project prj, enum ProjectField field, const char* value)
{
	assert(prj);
	fields_set_value(prj->fields, field, value);
}


/**
 * Sets the list of values associated with a field. The field will subsequently
 * "own" the list, and take responsibility to destroying it with the field set.
 * \param   prj      The project object.
 * \param   field    The index of the field to set.
 * \param   values   The list of new values for the field.
 */
void project_set_values(Project prj, enum ProjectField field, Strings values)
{
	assert(prj);
	fields_set_values(prj->fields, field, values);
}
