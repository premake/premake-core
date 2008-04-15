/**
 * \file   project.c
 * \brief  The project class.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/project.h"
#include "base/path.h"
#include "base/strings.h"


struct FieldInfo ProjectFieldInfo[] =
{
	{ "basedir",    StringField },
	{ "guid",       StringField },
	{ "location",   StringField },
	{ "name",       StringField },
	{  0,           0           }
};


DEFINE_CLASS(Project)
{
	Fields fields;
};


/**
 * Create and initialize a new project object.
 * \returns A new project object.
 */
Project project_create()
{
	Project prj = ALLOC_CLASS(Project);
	prj->fields = fields_create(ProjectFieldInfo);
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
 * Retrieve the GUID associated with a project.
 * \param   prj    The project to query.
 * \returns The GUID associated with the project, or NULL if the GUID has not been set.
 */
const char* project_get_guid(Project prj)
{
	return project_get_value(prj, ProjectGuid);
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
 * Set the base directory of the project.
 * \param   prj      The project object to modify.
 * \param   base_dir The new base directory.
 */
void project_set_base_dir(Project prj, const char* base_dir)
{
	project_set_value(prj, ProjectBaseDirectory, base_dir);
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
