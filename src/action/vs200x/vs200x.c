/**
 * \file   vs200x.c
 * \brief  General purpose Visual Studio support functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "vs200x.h"
#include "base/cstr.h"


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
