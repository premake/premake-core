/**
 * \file   vs200x_project_tests.cpp
 * \brief  Automated tests for Visual Studio project processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/vs200x/vs200x_project.h"
#include "base/env.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Encoding tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Encoding)
	{
		vs200x_project_encoding(prj, strm);
		CHECK_EQUAL(
			"<?xml version=\"1.0\" encoding=\"Windows-1252\"?>\r\n",
			buffer);
	}


	/**********************************************************************
	 * Project element tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VsProject_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_project_element(prj, strm);
		CHECK_EQUAL(
			"<VisualStudioProject\n"
			"\tProjectType=\"Visual C++\"\n"
			"\tVersion=\"7.00\"\n"
			"\tName=\"My Project\"\n"
			"\tProjectGUID=\"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"\tKeyword=\"Win32Proj\">\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsProject_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_project_element(prj, strm);
		CHECK_EQUAL(
			"<VisualStudioProject\n"
			"\tProjectType=\"Visual C++\"\n"
			"\tVersion=\"7.10\"\n"
			"\tName=\"My Project\"\n"
			"\tProjectGUID=\"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"\tKeyword=\"Win32Proj\">\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsProject_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_project_element(prj, strm);
		CHECK_EQUAL(
			"<VisualStudioProject\n"
			"\tProjectType=\"Visual C++\"\n"
			"\tVersion=\"8.00\"\n"
			"\tName=\"My Project\"\n"
			"\tProjectGUID=\"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"\tRootNamespace=\"MyProject\"\n"
			"\tKeyword=\"Win32Proj\"\n"
			"\t>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsProject_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_project_element(prj, strm);
		CHECK_EQUAL(
			"<VisualStudioProject\n"
			"\tProjectType=\"Visual C++\"\n"
			"\tVersion=\"9.00\"\n"
			"\tName=\"My Project\"\n"
			"\tProjectGUID=\"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"\tRootNamespace=\"MyProject\"\n"
			"\tKeyword=\"Win32Proj\"\n"
			"\tTargetFrameworkVersion=\"196613\"\n"
			"\t>\n",
			buffer);
	}


	/**********************************************************************
	 * Platforms tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Platforms)
	{
		env_set_action("vs2002");
		vs200x_project_platforms(prj, strm);
		CHECK_EQUAL(
			"\t<Platforms>\n"
			"\t\t<Platform\n"
			"\t\t\tName=\"Win32\"/>\n"
			"\t</Platforms>\n",
			buffer);
	}


	/**********************************************************************
	 * Tool files tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_project_tool_files(prj, strm);
		CHECK_EQUAL(
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_project_tool_files(prj, strm);
		CHECK_EQUAL(
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_project_tool_files(prj, strm);
		CHECK_EQUAL(
			"\t<ToolFiles>\n"
			"\t</ToolFiles>\n"
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_project_tool_files(prj, strm);
		CHECK_EQUAL(
			"\t<ToolFiles>\n"
			"\t</ToolFiles>\n"
			"\t<Configurations>\n",
			buffer);
	}



	/**********************************************************************
	 * Configuration element tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Configuration)
	{
		env_set_action("vs2002");
		vs200x_project_config_element(prj, strm);
		CHECK_EQUAL(
			"\t\t<Configuration\n"
			"\t\t\tName=\"Debug DLL|Win32\"\n"
			"\t\t\tOutputDirectory=\"$(SolutionDir)$(ConfigurationName)\"\n"
			"\t\t\tIntermediateDirectory=\"$(ConfigurationName)\"\n"
			"\t\t\tConfigurationType=\"1\"\n"
			"\t\t\tCharacterSet=\"2\">\n",
			buffer);
	}


	/**********************************************************************
	 * Tool element tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_VCALinkTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_alink_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCALinkTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCAppVerifierTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_app_verifier_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCAppVerifierTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCBscMakeTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_bsc_make_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCBscMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCCustomBuildTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_custom_build_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCustomBuildTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCFxCopTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_fx_cop_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCFxCopTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCManagedResourceCompilerTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_managed_resource_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManagedResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCManifestTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_manifest_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManifestTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCMIDLTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_midl_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCMIDLTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPreBuildEventTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_pre_build_event_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPreLinkEventTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_pre_link_event_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreLinkEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPostBuildEventTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_post_build_event_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPostBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCResourceCompilerTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_resource_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCWebDeploymentTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_web_deployment_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebDeploymentTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCWebServiceProxyGeneratorTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_web_service_proxy_generator_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebServiceProxyGeneratorTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCXDCMakeTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_xdc_make_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCXDCMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCXMLDataGeneratorTool)
	{
		env_set_action("vs2002");
		vs200x_project_vc_xml_data_generator_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCXMLDataGeneratorTool\"/>\n",
			buffer);
	}


	/**********************************************************************
	 * References section tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_project_references(prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_project_references(prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n"
			"\t<References>\n"
			"\t</References>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_project_references(prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n"
			"\t<References>\n"
			"\t</References>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_project_references(prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n"
			"\t<References>\n"
			"\t</References>\n",
			buffer);
	}


	/**********************************************************************
	 * Files section tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Files_OnNoFiles)
	{
		env_set_action("vs2002");
		vs200x_project_files(prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t</Files>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_Files_OnSingleCppFile)
	{
		env_set_action("vs2002");
		const char* values[] = { "Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t\t<File\n"
			"\t\t\tRelativePath=\".\\Hello.cpp\">\n"
			"\t\t</File>\n"
			"\t</Files>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_Files_OnUpperDirectory)
	{
		env_set_action("vs2002");
		const char* values[] = { "../../Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t\t<File\n"
			"\t\t\tRelativePath=\"..\\..\\Hello.cpp\">\n"
			"\t\t</File>\n"
			"\t</Files>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_Files_OnGroupedCppFile)
	{
		env_set_action("vs2002");
		const char* values[] = { "Src/Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t\t<Filter\n"
			"\t\t\tName=\"Src\"\n"
			"\t\t\tFilter=\"\">\n"
			"\t\t\t<File\n"
			"\t\t\t\tRelativePath=\".\\Src\\Hello.cpp\">\n"
			"\t\t\t</File>\n"
			"\t\t</Filter>\n"
			"\t</Files>\n",
			buffer);
	}


	/**********************************************************************
	 * Globals section tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Globals)
	{
		env_set_action("vs2002");
		vs200x_project_globals(prj, strm);
		CHECK_EQUAL(
			"\t<Globals>\n"
			"\t</Globals>\n"
			"</VisualStudioProject>\n",
			buffer);
	}
}
