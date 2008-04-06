/**
 * \file   solution.c
 * \brief  The Solution class, representing the top-level container for projects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/solution.h"
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
	Fields fields;
};


/**
 * Create and initialize a new solution object.
 * \returns A new solution object.
 */
Solution solution_create()
{
	Solution sln = ALLOC_CLASS(Solution);
	sln->fields = fields_create(SolutionFieldInfo);
	return sln;
}


/**
 * Destroy a solution object and release the associated memory.
 * \param   sln   The solution object to destroy.
 */
void solution_destroy(Solution sln)
{
	assert(sln);
	fields_destroy(sln->fields);
	free(sln);
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
