/**
 * \file   vs2008.c
 * \brief  Visual Studio 2008 project file generation action.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x.h"
#include "vs200x_solution.h"
#include "vs200x_project.h"


/** The project features supported by this action */
static SessionFeatures Features =
{
	{ "c", "c++", NULL },
};


/** The VS2008 solution writing process, for session_enumerate_objects() */
static SessionSolutionCallback SolutionCallbacks[] = 
{
	vs200x_solution_create,
	vs2008_solution_signature,
	vs2002_solution_projects,
	vs2005_solution_platforms,
	vs2005_solution_project_platforms,
	vs2005_solution_properties,
	NULL
};

/** The VS2008 project writing process, for session_enumerate_objects() */
static SessionProjectCallback ProjectCallbacks[] =
{
	vs200x_project_create,
	vs200x_project_encoding,
	vs200x_project_element,
	vs200x_project_platforms,
	vs200x_project_tool_files,
	session_enumerate_configurations,
	vs200x_project_references,
	vs200x_project_files,
	vs200x_project_globals,
	NULL
};

/** The VS2008 configuration writing process, for session_enumerate_configurations() */
static SessionProjectCallback ConfigCallbacks[] =
{
	vs200x_project_config_element,
	vs200x_project_vc_pre_build_event_tool,
	vs200x_project_vc_custom_build_tool,
	vs200x_project_vc_xml_data_generator_tool,
	vs200x_project_vc_web_service_proxy_generator_tool,
	vs200x_project_vc_midl_tool,
	vs200x_project_vc_cl_compiler_tool,
	vs200x_project_vc_managed_resource_compiler_tool,
	vs200x_project_vc_resource_compiler_tool,
	vs200x_project_vc_pre_link_event_tool,
	vs200x_project_vc_linker_tool,
	vs200x_project_vc_alink_tool,
	vs200x_project_vc_manifest_tool,
	vs200x_project_vc_xdc_make_tool,
	vs200x_project_vc_bsc_make_tool,
	vs200x_project_vc_fx_cop_tool,
	vs200x_project_vc_app_verifier_tool,
	vs200x_project_vc_post_build_event_tool,
	vs200x_project_config_end,
	NULL
};


/**
 * The Visual Studio 2008 action handler.
 * \param   sess   The active session object.
 * \returns OKAY if successful.
 */
int vs2008_action(Session sess)
{
	/* make sure I can support all of the features used in the session */
	if (session_validate(sess, &Features) != OKAY)
	{
		return !OKAY;
	}

	stream_writeline(Console, "Generating project files for Visual Studio 2008...");
	return session_enumerate_objects(sess, SolutionCallbacks, ProjectCallbacks, ConfigCallbacks);
}

