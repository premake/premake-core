/**
 * \file   env.c
 * \brief  Manage the runtime environment state.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "env.h"
#include "platform/platform.h"


static enum OS CurrentOS  = UnknownOS;
static const char* Action = NULL;


/**
 * Retrieve the current action being targeted. Will return NULL if no action
 * has been set.
 */
const char* env_get_action(void)
{
	return Action;
}


/**
 * Identify the target OS. This value will be set to the current OS by default,
 * but can be overridden by calling env_set_os_by_name().
 */
enum OS env_get_os(void)
{
	if (CurrentOS == UnknownOS)
	{
#if defined(PLATFORM_BSD)
		CurrentOS = BSD;
#elif defined(PLATFORM_LINUX)
		CurrentOS = Linux;
#elif defined(PLATFORM_MACOSX)
		CurrentOS = MacOSX;
#else
		CurrentOS = Windows;
#endif
	}
	return CurrentOS;
}


/**
 * Identify the target OS with a string name. This value will be set to the current 
 * OS by default, but can be overridden by calling env_set_os_by_name().
 */
const char* env_get_os_name(void)
{
	switch (env_get_os())
	{
	case BSD:
		return "BSD";
	case Linux:
		return "Linux";
	case MacOSX:
		return "MacOSX";
	case Windows:
		return "Windows";
	default:
		assert(0);
		return 0;
	}
}


/**
 * Returns true if the current OS matches the one provided.
 */
int env_is_os(enum OS id)
{
	return (env_get_os() == id);
}


/**
 * Set the action being targeted in this run.
 */
void env_set_action(const char* action)
{
	Action = action;
}


/**
 * Override the default OS identification, allowing generation of project files
 * targeted for other platforms (like cross-compiling).
 */
void env_set_os(enum OS id)
{
	CurrentOS = id;
}
