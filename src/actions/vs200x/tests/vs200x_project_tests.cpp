/**
 * \file   vs200x_project_tests.cpp
 * \brief  Automated tests for Visual Studio project processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/vs200x/vs200x_project.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Encoding tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200x_Encoding)
	{
		vs200x_project_encoding(sess, prj, strm);
		CHECK_EQUAL(
			"<?xml version=\"1.0\" encoding=\"Windows-1252\"?>\r\n",
			buffer);
	}


	/**********************************************************************
	 * Project element tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VsProject_OnVs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_element(sess, prj, strm);
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
		session_set_action(sess, "vs2003");
		vs200x_project_element(sess, prj, strm);
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
		session_set_action(sess, "vs2005");
		vs200x_project_element(sess, prj, strm);
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
		session_set_action(sess, "vs2008");
		vs200x_project_element(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_platforms(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_tool_files(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_project_tool_files(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_project_tool_files(sess, prj, strm);
		CHECK_EQUAL(
			"\t<ToolFiles>\n"
			"\t</ToolFiles>\n"
			"\t<Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsToolFiles_Defaults_OnVs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_project_tool_files(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_config_element(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_vc_alink_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCALinkTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCAppVerifierTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_app_verifier_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCAppVerifierTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCBscMakeTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_bsc_make_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCBscMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCCustomBuildTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_custom_build_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCustomBuildTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCFxCopTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_fx_cop_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCFxCopTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCManagedResourceCompilerTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_managed_resource_compiler_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManagedResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCManifestTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_manifest_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManifestTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCMIDLTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_midl_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCMIDLTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPreBuildEventTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_pre_build_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPreLinkEventTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_pre_link_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreLinkEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCPostBuildEventTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_post_build_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPostBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCResourceCompilerTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_resource_compiler_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCWebDeploymentTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_web_deployment_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebDeploymentTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCWebServiceProxyGeneratorTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_web_service_proxy_generator_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebServiceProxyGeneratorTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCXDCMakeTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_xdc_make_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCXDCMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_VCXMLDataGeneratorTool)
	{
		session_set_action(sess, "vs2002");
		vs200x_project_vc_xml_data_generator_tool(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_references(sess, prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_project_references(sess, prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n"
			"\t<References>\n"
			"\t</References>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_project_references(sess, prj, strm);
		CHECK_EQUAL(
			"\t</Configurations>\n"
			"\t<References>\n"
			"\t</References>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VsReferences_Defaults_OnVs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_project_references(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_files(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t</Files>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, Vs200x_Files_OnSingleCppFile)
	{
		session_set_action(sess, "vs2002");
		char* values[] = { "Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		char* values[] = { "../../Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		char* values[] = { "Src/Hello.cpp", 0 };
		SetField(prj, ProjectFiles, values);
		vs200x_project_files(sess, prj, strm);
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
		session_set_action(sess, "vs2002");
		vs200x_project_globals(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Globals>\n"
			"\t</Globals>\n"
			"</VisualStudioProject>\n",
			buffer);
	}
}
