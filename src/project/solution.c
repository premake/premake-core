/**
 * \file   solution.c
 * \brief  The Solution class, representing the top-level container for projects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/solution.h"
#include "base/array.h"
#include "base/path.h"
#include "base/strings.h"

#include "base/string.h"   /* <-- remove this? */


struct FieldInfo SolutionFieldInfo[] =
{
	{ "basedir",    StringField },
	{ "location",   StringField },
	{ "name",       StringField },
	{  0,           0           }
};


DEFINE_CLASS(Solution)
{
	Fields  fields;
	Strings configs;
	Array   projects;
	Strings project_names;
};


/**
 * Create and initialize a new solution object.
 * \returns A new solution object.
 */
Solution solution_create()
{
	Solution sln = ALLOC_CLASS(Solution);
	sln->fields = fields_create(SolutionFieldInfo);
	sln->configs  = strings_create();
	sln->projects = array_create();
	sln->project_names = NULL;
	return sln;
}


/**
 * Destroy a solution object and release the associated memory.
 * \param   sln   The solution object to destroy.
 */
void solution_destroy(Solution sln)
{
	int i, n;

	assert(sln);
	fields_destroy(sln->fields);
	strings_destroy(sln->configs);

	n = solution_num_projects(sln);
	for (i = 0; i < n; ++i)
	{
		Project prj = solution_get_project(sln, i);
		project_destroy(prj);
	}
	array_destroy(sln->projects);

	if (sln->project_names != NULL)
	{
		strings_destroy(sln->project_names);
	}

	free(sln);
}


/**
 * Add a configuration name to a solution.
 * \param   sln          The solution to contain the project.
 * \param   config_name  The name of the configuration add.
 */
void solution_add_config_name(Solution sln, const char* config_name)
{
	assert(sln);
	assert(config_name);
	strings_add(sln->configs, config_name);
}


/**
 * Add a project to a solution.
 * \param   sln     The solution to contain the project.
 * \param   prj     The project to add.
 */
void solution_add_project(Solution sln, Project prj)
{	
	assert(sln);
	assert(prj);
	array_add(sln->projects, prj);
}


/**
 * Get the base directory for the solution; any properties containing relative
 * paths are relative to this location.
 * \param   sln     The solution object to query.
 * \returns The base directory, or NULL if no directory has been set.
 */
const char* solution_get_base_dir(Solution sln)
{
	return solution_get_value(sln, SolutionBaseDirectory);
}


/**
 * Get the configuration name at a given index.
 * \param   sln      The solution to query.
 * \param   index    The configuration index to query.
 * \returns The configuration name at the given index.
 */
const char* solution_get_config_name(Solution sln, int index)
{
	const char* name;
	assert(sln);
	name = strings_item(sln->configs, index);
	return name;
}


/**
 * Get the list of configuration names.
 * \param   sln      The solution to query.
 * \returns The configuration name at the given index.
 */
Strings solution_get_config_names(Solution sln)
{
	assert(sln);
	return sln->configs;
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
 * Retrieve the output location (the relative path from the base directory to the
 * target output directory) for this solution.
 * \param   sln        The solution object to modify.
 * \returns The solution output location, or NULL if no location has been set.
 */
const char* solution_get_location(Solution sln)
{
	return solution_get_value(sln, SolutionLocation);
}


/**
 * Get the name of the solution.
 * \returns The name, if set, NULL otherwise.
 */
const char* solution_get_name(Solution sln)
{
	return solution_get_value(sln, SolutionName);
}


/**
 * Retrieve a project from the solution.
 * \param   sln      The solution to query.
 * \param   index    The index of the project to retreive.
 * \returns The project at the given index within the solution.
 */
Project solution_get_project(Solution sln, int index)
{
	Project prj;

	assert(sln);

	prj = (Project)array_item(sln->projects, index);
	return prj;
}


/**
 * Retrieve the names of all projects contained by the solution.
 * \param   sln      The solution to query.
 * \returns A list of project names.
 */
Strings solution_get_project_names(Solution sln)
{
	assert(sln);
	if (sln->project_names == NULL)
	{
		int i, n;
		sln->project_names = strings_create();
		n = solution_num_projects(sln);
		for (i = 0; i < n; ++i)
		{
			Project prj = solution_get_project(sln, i);
			const char* name = project_get_name(prj);
			strings_add(sln->project_names, name);
		}
	}
	return sln->project_names;
}


/**
 * Retrieve a string (single value) fields from a solution, using the field indices.
 * \param   sln      The solution object to query.
 * \param   field    The index of the field to query.
 * \returns The value of the field if set, of NULL.
 */
const char* solution_get_value(Solution sln, enum SolutionField field)
{
	assert(sln);
	return fields_get_value(sln->fields, field);
}


/**
 * Return the number of configurations contained by this solution.
 * \param   sln      The solution to query.
 * \returns The number of configurations contained by the solution.
 */
int solution_num_configs(Solution sln)
{
	assert(sln);
	return strings_size(sln->configs);
}


/**
 * Return the number of projects contained by this solution.
 * \param   sln      The solution to query.
 * \returns The number of projects contained by the solution.
 */
int solution_num_projects(Solution sln)
{
	assert(sln);
	return array_size(sln->projects);
}


/**
 * Set the base directory of the solution.
 * \param   sln      The solution object to modify.
 * \param   base_dir The new base directory.
 */
void solution_set_base_dir(Solution sln, const char* base_dir)
{
	solution_set_value(sln, SolutionBaseDirectory, base_dir);
}


/*
 * Set the output location (the relative path from the base directory to the
 * target output directory) for this solution.
 * \param   sln        The solution object to modify.
 * \param   location   The new output location.
 */
void solution_set_location(Solution sln, const char* location)
{
	solution_set_value(sln, SolutionLocation, location);
}


/**
 * Set the name of the solution.
 * \param sln    The solution object.
 * \param name   The new for the solution.
 */
void solution_set_name(Solution sln, const char* name)
{
	solution_set_value(sln, SolutionName, name);
}


/**
 * Set a string (single value) field on a solution, using the field indices.
 * \param   sln      The solution object.
 * \param   field    The field to set.
 * \param   value    The new value for the field.
 */
void solution_set_value(Solution sln, enum SolutionField field, const char* value)
{
	assert(sln);
	fields_set_value(sln->fields, field, value);
}
