/**
 * \file   solution.c
 * \brief  The Solution class, representing the top-level container for projects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "solution.h"
#include "session.h"
#include "objects_internal.h"
#include "base/array.h"
#include "base/path.h"
#include "base/strings.h"


struct FieldInfo SolutionFieldInfo[] =
{
	{ "basedir",        StringField,  NULL                       },
	{ "configurations", ListField,    NULL                       },
	{ "language",       StringField,  project_is_valid_language  },
	{ "location",       StringField,  NULL                       },
	{ "name",           StringField,  NULL                       },
	{  0,               0,            NULL                        }
};


DEFINE_CLASS(Solution)
{
	Session session;
	Fields  fields;
	Array   projects;
	Blocks  blocks;
};


/**
 * Create and initialize a new solution object.
 */
Solution solution_create()
{
	Solution sln  = ALLOC_CLASS(Solution);
	sln->session  = NULL;
	sln->fields   = fields_create(SolutionFieldInfo);
	sln->projects = array_create();
	sln->blocks   = blocks_create();
	return sln;
}


/**
 * Destroy a solution object and release the associated memory.
 */
void solution_destroy(Solution sln)
{
	int i, n;

	assert(sln);
	fields_destroy(sln->fields);
	blocks_destroy(sln->blocks);

	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		project_destroy(prj);
	}
	array_destroy(sln->projects);

	free(sln);
}


/**
 * Add a configuration name to a solution.
 */
void solution_add_config(Solution sln, const char* config_name)
{
	assert(sln);
	assert(config_name);
	fields_add_value(sln->fields, SolutionConfigurations, config_name);
}


/**
 * Add a project to a solution.
 */
void solution_add_project(Solution sln, Project prj)
{	
	assert(sln);
	assert(prj);
	array_add(sln->projects, prj);
	project_set_solution(prj, sln);
}


/**
 * Get the base directory for the solution; any properties containing relative
 * paths are relative to this location.
 */
const char* solution_get_base_dir(Solution sln)
{
	return solution_get_value(sln, SolutionBaseDirectory);
}


/**
 * Retrieve the list of configuration blocks associated with a solution.
 */
Blocks solution_get_blocks(Solution sln)
{
	assert(sln);
	return sln->blocks;
}


/**
 * Get the configuration name at a given index.
 */
const char* solution_get_config(Solution sln, int index)
{
	Strings names;
	const char* name;
	assert(sln);
	names = fields_get_values(sln->fields, SolutionConfigurations);
	name = strings_item(names, index);
	return name;
}


/**
 * Get the list of configuration names.
 */
Strings solution_get_configs(Solution sln)
{
	assert(sln);
	return fields_get_values(sln->fields, SolutionConfigurations);
}


/**
 * Retrieve the fields object for this solution; used to unload values from the script.
 */
Fields solution_get_fields(Solution sln)
{
	assert(sln);
	return sln->fields;
}


/**
 * Get the path to the solution output file, using the provided file extension.
 * \param   sln      The solution object to query.
 * \param   basename The base filename; if NULL the solution name will be used.
 * \param   ext      The file extension to be used on the filename; may be NULL.
 * \returns The path to the solution file.
 */
const char* solution_get_filename(Solution sln, const char* basename, const char* ext)
{
	const char* base_dir;
	const char* location;
	const char* directory;
	const char* result;

	assert(sln);

	if (!basename)
	{
		basename = solution_get_name(sln);
	}

	if (!ext)
	{
		ext = "";
	}

	base_dir = solution_get_base_dir(sln);
	location = solution_get_location(sln);
	directory = path_join(base_dir, location);

	result = path_assemble(directory, basename, ext);
	return result;
}


/**
 * Get the programming language set globally for the solution.
 */
const char* solution_get_language(Solution sln)
{
	return solution_get_value(sln, SolutionLanguage);
}


/**
 * Retrieve the output location (the relative path from the base directory to the
 * target output directory) for this solution.
 */
const char* solution_get_location(Solution sln)
{
	return solution_get_value(sln, SolutionLocation);
}


/**
 * Get the name of the solution.
 */
const char* solution_get_name(Solution sln)
{
	return solution_get_value(sln, SolutionName);
}


/**
 * Retrieve a project from the solution.
 */
Project solution_get_project(Solution sln, int index)
{
	Project prj;

	assert(sln);

	prj = (Project)array_item(sln->projects, index);
	return prj;
}


/**
 * Retrieve the session which contains this solution.
 */
Session solution_get_session(Solution sln)
{
	assert(sln);
	return sln->session;
}


/**
 * Retrieve a string (single value) fields from a solution, using the field indices.
 */
const char* solution_get_value(Solution sln, enum SolutionField field)
{
	assert(sln);
	return fields_get_value(sln->fields, field);
}


/**
 * Return the number of configurations contained by this solution.
 */
int solution_num_configs(Solution sln)
{
	Strings names;
	assert(sln);
	names = fields_get_values(sln->fields, SolutionConfigurations);
	return strings_size(names);
}


/**
 * Return the number of projects contained by this solution.
 */
int solution_num_projects(Solution sln)
{
	assert(sln);
	return array_size(sln->projects);
}


/**
 * Set the base directory of the solution.
 */
void solution_set_base_dir(Solution sln, const char* base_dir)
{
	solution_set_value(sln, SolutionBaseDirectory, base_dir);
}


/**
 * Set the global programming language for the solution.
 */
void solution_set_language(Solution sln, const char* language)
{
	solution_set_value(sln, SolutionLanguage, language);
}


/*
 * Set the output location (the relative path from the base directory to the
 * target output directory) for this solution.
 */
void solution_set_location(Solution sln, const char* location)
{
	solution_set_value(sln, SolutionLocation, location);
}


/**
 * Set the name of the solution.
 */
void solution_set_name(Solution sln, const char* name)
{
	solution_set_value(sln, SolutionName, name);
}


/**
 * Associate this solution with a session (internal).
 */
void solution_set_session(Solution sln, Session sess)
{
	assert(sln);
	sln->session = sess;
}


/**
 * Set a string (single value) field on a solution, using the field indices.
 */
void solution_set_value(Solution sln, enum SolutionField field, const char* value)
{
	assert(sln);
	fields_set_value(sln->fields, field, value);
}
