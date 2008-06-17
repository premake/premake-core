/**
 * \file   vs200x_project.c
 * \brief  Visual Studio multiple-version project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "action/action.h"
#include "vs200x.h"
#include "vs200x_project.h"
#include "vs200x_config.h"
#include "base/cstr.h"
#include "base/path.h"


/**
 * Write the opening [Configuration] element and attributes.
 */
int vs200x_project_config_element(Session sess, Project prj, Stream strm)
{
	int z = OKAY;
	const char* cfg_name = project_get_configuration_filter(prj);
	z |= stream_write(strm, "\t\t<Configuration");
	z |= vs200x_attribute(strm, 3, "Name", "%s|Win32", cfg_name);
	z |= vs200x_attribute(strm, 3, "OutputDirectory", "$(SolutionDir)$(ConfigurationName)");
	z |= vs200x_attribute(strm, 3, "IntermediateDirectory", "$(ConfigurationName)");
	z |= vs200x_attribute(strm, 3, "ConfigurationType", "1");
	z |= vs200x_config_character_set(sess, strm);
	z |= vs200x_element_end(sess, strm, 2, ">");
	return z;
}


/**
 * Write the closing [Configuration] element.
 */
int vs200x_project_config_end(Session sess, Project prj, Stream strm)
{
	UNUSED(sess);
	UNUSED(prj);
	return stream_writeline(strm, "\t\t</Configuration>");
}


/**
 * Create a new output stream for a project, and make it active for subsequent writes.
 */
int vs200x_project_create(Session sess, Project prj, Stream strm)
{
	/* create the project file */
	const char* extension = vs200x_project_file_extension(prj);
	const char* filename  = project_get_filename(prj, NULL, extension);
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(sess, strm);
	return OKAY;
}


/**
 * Write the root [VisualStudioProject] element and attributes.
 */
int vs200x_project_element(Session sess, Project prj, Stream strm)
{
	int version, z;
	const char* prj_ver;
	const char* prj_name = project_get_name(prj);
	const char* prj_guid = project_get_guid(prj);

	version = vs200x_get_target_version(sess);
	switch (version)
	{
	default:
		prj_ver = "7.00";  break;
	case 2003:
		prj_ver = "7.10";  break;
	case 2005:
		prj_ver = "8.00";  break;
	case 2008:
		prj_ver = "9.00";  break;
	}

	z  = stream_write(strm, "<VisualStudioProject");
	z |= vs200x_attribute(strm, 1, "ProjectType", "Visual C++");
	z |= vs200x_attribute(strm, 1, "Version", prj_ver);
	z |= vs200x_attribute(strm, 1, "Name", prj_name);
	z |= vs200x_attribute(strm, 1, "ProjectGUID", "{%s}", prj_guid);
	if (version > 2003)
	{
		z |= vs200x_attribute(strm, 1, "RootNamespace", prj_name);
	}
	z |= vs200x_attribute(strm, 1, "Keyword", "Win32Proj");
	if (version > 2005)
	{
		z |= vs200x_attribute(strm, 1, "TargetFrameworkVersion", "196613");
	}
	z |= vs200x_element_end(sess, strm, 0, ">");
	return z;
}


/**
 * Write the file encoding at the start of the project file.
 */
int vs200x_project_encoding(Session sess, Project prj, Stream strm)
{
	UNUSED(sess);
	UNUSED(prj);
	stream_set_newline(strm, "\r\n");
	return stream_writeline(strm, "<?xml version=\"1.0\" encoding=\"Windows-1252\"?>");
}


/**
 * Write an individual file entry to the project file; callback for action_source_tree().
 * \param   sess      The current execution session context.
 * \param   prj       The current project; contains the file being enumerated.
 * \param   strm      The active output stream; for writing the file markup.
 * \param   filename  The name of the file to process.
 * \param   state     One of the ActionSourceStates, enabling file grouping.
 * \returns OKAY if successful.
 */
int vs200x_project_file(Session sess, Project prj, Stream strm, const char* filename, int state)
{
	const char* name;
	const char* ptr;
	int depth, z = OKAY;

	/* figure out the grouping depth, skipping over any leading dot directories */
	depth = 2;

	ptr = filename;
	while (cstr_starts_with(ptr, "../"))
	{
		ptr += 3;
	}

	ptr = strchr(ptr, '/');
	while (ptr != NULL)
	{
		depth++;
		ptr = strchr(ptr + 1, '/');
	}

	/* group name is just the last bit of the path */
	name = path_filename(filename);

	/* use the Windows path separator */
	filename = path_translate(filename, "\\");

	switch (state)
	{
	case GroupStart:
		if (strlen(filename) > 0 && !cstr_eq(name, ".."))
		{
			z |= stream_write_n(strm, "\t", depth);
			z |= stream_write(strm, "<Filter");
			z |= vs200x_attribute(strm, depth + 1, "Name", name);
			z |= vs200x_attribute(strm, depth + 1, "Filter", "");
			z |= vs200x_element_end(sess, strm, depth, ">");
		}
		break;

	case GroupEnd:
		if (strlen(filename) > 0 && !cstr_eq(name, ".."))
		{
			z |= stream_write_n(strm, "\t", depth);
			z |= stream_writeline(strm, "</Filter>");
		}
		break;

	case SourceFile:
		z |= stream_write_n(strm, "\t", depth);
		z |= stream_write(strm, "<File");
		ptr = (filename[0] == '.') ? "" : ".\\";
		z |= vs200x_attribute(strm, depth + 1, "RelativePath", "%s%s", ptr, filename);
		z |= vs200x_element_end(sess, strm, depth, ">");
		z |= stream_write_n(strm, "\t", depth);
		z |= stream_writeline(strm, "</File>");
		break;
	}

	UNUSED(prj);
	return z;
}


/**
 * Write out the [Files] element.
 */
int vs200x_project_files(Session sess, Project prj, Stream strm)
{
	int z = OKAY;
	z |= stream_writeline(strm, "\t<Files>");
	z |= action_source_tree(sess, prj, strm, vs200x_project_file);
	z |= stream_writeline(strm, "\t</Files>");
	return z;
}


/**
 * Write out the [Globals] element.
 */
int vs200x_project_globals(Session sess, Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(sess);
	UNUSED(prj);
	z |= stream_writeline(strm, "\t<Globals>");
	z |= stream_writeline(strm, "\t</Globals>");
	z |= stream_writeline(strm, "</VisualStudioProject>");
	return z;
}


/**
 * Write out the platforms section of a project file.
 */
int vs200x_project_platforms(Session sess, Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "\t<Platforms>");
	z |= stream_write(strm, "\t\t<Platform");
	z |= vs200x_attribute(strm, 3, "Name", "Win32");
	z |= vs200x_element_end(sess, strm, 2, "/>");
	z |= stream_writeline(strm, "\t</Platforms>");
	return OKAY;
}


/**
 * Write out the [References] element and attributes.
 */
int vs200x_project_references(Session sess, Project prj, Stream strm)
{
	int z;
	UNUSED(prj);
	z  = stream_writeline(strm, "\t</Configurations>");
	if (vs200x_get_target_version(sess) > 2002)
	{
		z |= stream_writeline(strm, "\t<References>");
		z |= stream_writeline(strm, "\t</References>");
	}
	return z;
}


/**
 * Write out the [ToolFiles] section of a Visual Studio project.
 */
int vs200x_project_tool_files(Session sess, Project prj, Stream strm)
{
	int version, z = OKAY;
	UNUSED(prj);

	version = vs200x_get_target_version(sess);
	if (version > 2003)
	{
		z |= stream_writeline(strm, "\t<ToolFiles>");
		z |= stream_writeline(strm, "\t</ToolFiles>");
	}
	z |= stream_writeline(strm, "\t<Configurations>");
	return z;
}


/**
 * Common function to write an empty [Tool] element.
 */
static int vs200x_project_vc_empty_tool(Session sess, Project prj, Stream strm, const char* name)
{
	int z;
	UNUSED(prj);
	z  = stream_write(strm, "\t\t\t<Tool");
	z |= vs200x_attribute(strm, 4, "Name", name);
	z |= vs200x_element_end(sess, strm, 3, "/>");
	return z;
}


/**
 * Write the VCALinkTool [Tool] element and attributes.
 */
int vs200x_project_vc_alink_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCALinkTool");
}


/**
 * Write the VCAppVerifierTool [Tool] element and attributes.
 */
int vs200x_project_vc_app_verifier_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCAppVerifierTool");
}


/**
 * Write the VCBscMakeTool [Tool] element and attributes.
 */
int vs200x_project_vc_bsc_make_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCBscMakeTool");
}


/**
 * Write the VCCLCompilerTool [Tool] element and attributes.
 */
int vs200x_project_vc_cl_compiler_tool(Session sess, Project prj, Stream strm)
{
	int version, z;
	UNUSED(prj);
	version = vs200x_get_target_version(sess);
	z  = stream_write(strm, "\t\t\t<Tool");
	z |= vs200x_attribute(strm, 4, "Name", "VCCLCompilerTool");
	z |= vs200x_attribute(strm, 4, "Optimization", "0");
	z |= vs200x_attribute(strm, 4, "MinimalRebuild", vs200x_true(sess));
	z |= vs200x_attribute(strm, 4, "BasicRuntimeChecks", "3");
	z |= vs200x_attribute(strm, 4, "RuntimeLibrary", "3");
	z |= vs200x_config_runtime_type_info(sess, strm, prj);
	z |= vs200x_config_use_precompiled_header(sess, strm, prj);
	z |= vs200x_attribute(strm, 4, "WarningLevel", "3");
	z |= vs200x_config_detect_64bit_portability(sess, strm, prj);
	z |= vs200x_attribute(strm, 4, "DebugInformationFormat", "4");
	z |= vs200x_element_end(sess, strm, 3, "/>");
	return z;
}


/**
 * Write the VCCustomBuildTool [Tool] element and attributes.
 */
int vs200x_project_vc_custom_build_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCCustomBuildTool");
}


/**
 * Write the VCFxCopTool [Tool] element and attributes.
 */
int vs200x_project_vc_fx_cop_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCFxCopTool");
}


/**
 * Write the VCLinkerTool [Tool] element and attributes.
 */
int vs200x_project_vc_linker_tool(Session sess, Project prj, Stream strm)
{
	int z;
	UNUSED(prj);
	z  = stream_write(strm, "\t\t\t<Tool");
	z |= vs200x_attribute(strm, 4, "Name", "VCLinkerTool");
	z |= vs200x_attribute(strm, 4, "LinkIncremental", "2");
	z |= vs200x_attribute(strm, 4, "GenerateDebugInformation", vs200x_true(sess));
	z |= vs200x_attribute(strm, 4, "SubSystem", "1");
	z |= vs200x_attribute(strm, 4, "EntryPointSymbol", "mainCRTStartup");
	z |= vs200x_attribute(strm, 4, "TargetMachine", "1");
	z |= vs200x_element_end(sess, strm, 3, "/>");
	return z;
}


/**
 * Write the VCManagedResourceCompilerTool [Tool] element and attributes.
 */
int vs200x_project_vc_managed_resource_compiler_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCManagedResourceCompilerTool");
}


/**
 * Write the VCManifestTool [Tool] element and attributes.
 */
int vs200x_project_vc_manifest_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCManifestTool");
}


/**
 * Write the VCMIDLTool [Tool] element and attributes.
 */
int vs200x_project_vc_midl_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCMIDLTool");
}


/**
 * Write the VCPreBuildEventTool [Tool] element and attributes.
 */
int vs200x_project_vc_pre_build_event_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCPreBuildEventTool");
}


/**
 * Write the VCPreLinkEventTool [Tool] element and attributes.
 */
int vs200x_project_vc_pre_link_event_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCPreLinkEventTool");
}


/**
 * Write the VCPostBuildEventTool [Tool] element and attributes.
 */
int vs200x_project_vc_post_build_event_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCPostBuildEventTool");
}


/**
 * Write the VCResourceCompiler [Tool] element and attributes.
 */
int vs200x_project_vc_resource_compiler_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCResourceCompilerTool");
}


/**
 * Write the VCWebDeploymentTool [Tool] element and attributes.
 */
int vs200x_project_vc_web_deployment_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCWebDeploymentTool");
}


/**
 * Write the VCWebServiceProxyGeneratorTool [Tool] element and attributes.
 */
int vs200x_project_vc_web_service_proxy_generator_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCWebServiceProxyGeneratorTool");
}


/**
 * Write the VCXDCMakeTool [Tool] element and attributes.
 */
int vs200x_project_vc_xdc_make_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCXDCMakeTool");
}


/**
 * Write the VCXMLDataGeneratorTool [Tool] element and attributes.
 */
int vs200x_project_vc_xml_data_generator_tool(Session sess, Project prj, Stream strm)
{
	return vs200x_project_vc_empty_tool(sess, prj, strm, "VCXMLDataGeneratorTool");
}
