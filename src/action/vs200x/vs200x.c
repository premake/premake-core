/**
 * \file   vs200x.c
 * \brief  General purpose Visual Studio support functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "base/cstr.h"
#include "base/error.h"


/**
 * Converts the session action string to a Visual Studio version number.
 * \param   sess   The current execution session.
 * \returns The Visual Studio version number corresponding to the current action.
 */
int vs200x_get_target_version(Session sess)
{
	const char* action = session_get_action(sess);
	if (cstr_eq(action, "vs2002"))
	{
		return 2002;
	}
	else if (cstr_eq(action, "vs2003"))
	{
		return 2003;
	}
	else if (cstr_eq(action, "vs2005"))
	{
		return 2005;
	}
	else
	{
		assert(0);
		return 0;
	}
}


/**
 * Return the appropriate file extension for a particular project.
 * \param   prj    The project object.
 * \returns The appropriate project file extension, based on the project settings.
 */
const char* vs200x_project_file_extension(Project prj)
{
	const char* language = project_get_language(prj);
	if (cstr_eq(language, "c") || cstr_eq(language, "c++"))
	{
		return ".vcproj";
	}
	else
	{
		error_set("unsupported language '%s'", language); 
		return NULL;
	}
}


/**
 * Returns the Visual Studio GUID for a particular project type.
 * \param   language   The programming language used in the project.
 * \returns The GUID corresponding the programming language.
 */
const char* vs200x_tool_guid(const char* language)
{
	if (cstr_eq(language, "c") || cstr_eq(language, "c++"))
	{
		return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942";
	}
	else if (cstr_eq(language, "c#"))
	{
		return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC";
	}
	else
	{
		error_set("unsupported language '%s'", language); 
		return NULL;
	}
}


/**
 * Make sure all of the features described in the sesson are supported
 * by the Visual Studio actions.
 * \param   sess    The session to validate.
 * \returns OKAY if the session can be supported.
 */
int vs200x_validate_session(Session sess)
{
	int si, sn;
	assert(sess);

	sn = session_num_solutions(sess);
	for (si = 0; si < sn; ++si)
	{
		int pi, pn;
		Solution sln = session_get_solution(sess, si);

		pn = solution_num_projects(sln);
		for (pi = 0; pi < pn; ++pi)
		{
			const char* value;
			Project prj = solution_get_project(sln, pi);

			/* check for a recognized language */
			value = project_get_language(prj);
			if (!cstr_eq(value, "c") && !cstr_eq(value, "c++"))
			{
				error_set("%s is not currently supported for Visual Studio", value);
				return !OKAY;
			}
		}
	}

	return OKAY;
}
