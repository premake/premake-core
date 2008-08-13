/**
 * \file   project.c
 * \brief  The project class.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "solution.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/env.h"
#include "base/guid.h"
#include "base/path.h"
#include "base/strings.h"


FieldInfo ProjectFieldInfo[] =
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
	Blocks blocks;
	Fields fields;
	Strings config_cache[NumBlockFields];
	const char* active_config;
};


/**
 * Create and initialize a new project object.
 */
Project project_create()
{
	int i;

	Project prj = ALLOC_CLASS(Project);
	prj->solution = NULL;
	prj->blocks = blocks_create();
	prj->fields = fields_create(ProjectFieldInfo);
	prj->active_config = NULL;

	for (i = 0; i < NumBlockFields; ++i)
	{
		prj->config_cache[i] = NULL;
	}

	return prj;
}


/**
 * Destroy a project object and release the associated memory.
 */
void project_destroy(Project prj)
{
	int i;

	assert(prj);	
	blocks_destroy(prj->blocks);
	fields_destroy(prj->fields);
	for (i = 0; i < NumBlockFields; ++i)
	{
		if (prj->config_cache[i] != NULL)
			strings_destroy(prj->config_cache[i]);
	}
	free(prj);
}



/**
 * Get the base directory for the project; any properties containing relative
 * paths are relative to this location.
 */
const char* project_get_base_dir(Project prj)
{
	return project_get_value(prj, ProjectBaseDir);
}


/**
 * Retrieve the list of configuration blocks associated with a project.
 */
Blocks project_get_blocks(Project prj)
{
	assert(prj);
	return prj->blocks;
}



/**
 * Scans a list of blocks and appends any values found to the provided list.
 */
static void project_get_values_from_blocks(Project prj, Strings values, Blocks blks, enum BlockField field)
{
	int i, n = blocks_size(blks);
	for (i = 0; i < n; ++i)
	{
		Block blk = blocks_item(blks, i);

		if (block_applies_to(blk, prj->active_config))
		{
			Strings block_values = block_get_values(blk, field);
			strings_append(values, block_values);
		}
	}
}


/**
 * Retrieve the currently active configuration name; only settings contained by
 * blocks targeted to this configuration will be accessible. Returns NULL if no
 * configuration has been selected, in which case only global settings will 
 * be available.
 */
const char* project_get_config(Project prj)
{
	assert(prj);
	return prj->active_config;
}


/**
 * Retrieve a list value from the project configuration, respecting the current filter set.
 */
Strings project_get_config_values(Project prj, enum BlockField field)
{
	Strings values;

	assert(prj);
	assert(field >= 0 && field < NumBlockFields);

	values = strings_create();

	/* The "cache" just keeps track of all lists that I return to callers; I will
	 * take responsibility for destroying the lists, so the callers don't have to
	 * do it themselves. A bit of complexity here to simplify the action handers. */
	if (prj->config_cache[field] != NULL)
	{
		strings_destroy(prj->config_cache[field]);
	}
	prj->config_cache[field] = values;

	project_get_values_from_blocks(prj, values, solution_get_blocks(prj->solution), field);
	project_get_values_from_blocks(prj, values, project_get_blocks(prj), field);
	return values;
}


/**
 * Retrieve the list of preprocessor defines, using the current configuration filter.
 */
Strings project_get_defines(Project prj)
{
	Strings values = project_get_config_values(prj, BlockDefines);
	return values;
}


/**
 * Retrieve the fields object for this project; used to unload values from the script.
 */
Fields project_get_fields(Project prj)
{
	assert(prj);
	return prj->fields;
}


/**
 * Get the path to the project output file, using the provided file name and extension.
 * \param   prj      The project object to query.
 * \param   basename The base filename; if NULL the project name will be used.
 * \param   ext      The file extension to be used on the filename; may be NULL.
 * \returns The path to the project file.
 */
const char* project_get_filename(Project prj, const char* basename, const char* ext)
{
	const char* location = project_get_location(prj);
	if (!basename)
	{
		basename = project_get_name(prj);
	}
	return path_assemble(location, basename, ext);
}


/**
 * Get the relative path from the solution to the project file, using the 
 * provided file name and extension.
 * \param   prj      The project object to query.
 * \param   basename The base filename; if NULL the project name will be used.
 * \param   ext      The file extension to be used on the filename; may be NULL.
 * \returns The path to the project file.
 */
const char* project_get_filename_relative(Project prj, const char* basename, const char* ext)
{
	const char* sln_location;
	const char* abs_filename;
	assert(prj);
	assert(prj->solution);

	sln_location = solution_get_location(prj->solution);
	abs_filename = project_get_filename(prj, basename, ext);

	return path_relative(sln_location, abs_filename);
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
	return project_get_value(prj, ProjectGuid);
}


/**
 * Get the programming language used by the project.
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
 */
const char* project_get_location(Project prj)
{
	return project_get_value(prj, ProjectLocation);
}


/**
 * Get the name of the project.
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
	if (env_is_os(Windows))
	{
		strcat(buffer, ".exe");
	}
	return buffer;
}


/**
 * Retrieve the session which contains this project.
 */
Session project_get_session(Project prj)
{
	assert(prj);
	return solution_get_session(prj->solution);
}


/**
 * Retrieve the solution associated with this project (internal).
 */
Solution project_get_solution(Project prj)
{
	return prj->solution;
}


/**
 * Retrieve a string (single value) fields from a project, using the field indices.
 */
const char* project_get_value(Project prj, enum ProjectField field)
{
	assert(prj);
	return fields_get_value(prj->fields, field);
}


/**
 * Returns true if the specified language is recognized. Current valid language strings
 * are 'c', 'c++', and 'c#'.
 */
int project_is_valid_language(const char* language)
{
	return (cstr_eq(language, "c") ||
	        cstr_eq(language, "c++") ||
			cstr_eq(language, "c#"));
}


/**
 * Set the base directory of the project.
 */
void project_set_base_dir(Project prj, const char* base_dir)
{
	project_set_value(prj, ProjectBaseDir, base_dir);
}


/**
 * Selects a particular configuration; any subsequent calls to retrieve settings will
 * only return values which are part of this configuration. A value of NULL will clear
 * the configuration, and only return global settings.
 */
void project_set_config(Project prj, const char* cfg_name)
{
	assert(prj);
	prj->active_config = cfg_name;
}


/**
 * Set the GUID associated with a project. The GUID is required by the Visual
 * Studio generators, and must be unique per project.
 */
void project_set_guid(Project prj, const char* guid)
{
	project_set_value(prj, ProjectGuid, guid);
}


/**
 * Set the programming language used by a project.
 */
void project_set_language(Project prj, const char* language)
{
	project_set_value(prj, ProjectLanguage, language);
}


/**
 * Set the output location (the relative path from the base directory to the
 * target output directory) for this project.
 */
void project_set_location(Project prj, const char* location)
{
	project_set_value(prj, ProjectLocation, location);
}


/**
 * Set the name of the project.
 */
void project_set_name(Project prj, const char* name)
{
	project_set_value(prj, ProjectName, name);
}


/**
 * Associate a solution with this project (internal).
 */
void project_set_solution(Project prj, Solution sln)
{
	assert(prj);
	prj->solution = sln;
}


/**
 * Set a string (single value) field on a project, using the field indices.
 */
void project_set_value(Project prj, enum ProjectField field, const char* value)
{
	assert(prj);
	fields_set_value(prj->fields, field, value);
}


/**
 * Sets the list of values associated with a field. The field will subsequently
 * "own" the list, and take responsibility to destroying it with the field set.
 */
void project_set_values(Project prj, enum ProjectField field, Strings values)
{
	assert(prj);
	fields_set_values(prj->fields, field, values);
}
