/**
 * \file   vs200x_project_tests.cpp
 * \brief  Automated tests for Visual Studio project processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x_project.h"
}


struct FxVsProject : FxAction
{
	FxVsProject()
	{
		session_set_action(sess, "vs2002");
	}
};


SUITE(action)
{
	/**********************************************************************
	 * Configuration element tests
	 **********************************************************************/

	TEST_FIXTURE(FxVsProject, Vs200x_Configuration)
	{
		vs200x_project_config_element(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t<Configuration\n"
			"\t\t\tName=\"Debug|Win32\"\n"
			"\t\t\tOutputDirectory=\"$(SolutionDir)$(ConfigurationName)\"\n"
			"\t\t\tIntermediateDirectory=\"$(ConfigurationName)\"\n"
			"\t\t\tConfigurationType=\"1\"\n"
			"\t\t\tCharacterSet=\"2\">\n",
			buffer);
	}


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
	 * Platforms tests
	 **********************************************************************/

	TEST_FIXTURE(FxVsProject, Vs200x_Platforms)
	{
		vs200x_project_platforms(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Platforms>\n"
			"\t\t<Platform\n"
			"\t\t\tName=\"Win32\"/>\n"
			"\t</Platforms>\n",
			buffer);
	}


	/**********************************************************************
	 * Tool element tests
	 **********************************************************************/

	TEST_FIXTURE(FxVsProject, Vs200x_VCALinkTool)
	{
		vs200x_project_vc_alink_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCALinkTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCAppVerifierTool)
	{
		vs200x_project_vc_app_verifier_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCAppVerifierTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCBscMakeTool)
	{
		vs200x_project_vc_bsc_make_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCBscMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCCustomBuildTool)
	{
		vs200x_project_vc_custom_build_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCustomBuildTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCFxCopTool)
	{
		vs200x_project_vc_fx_cop_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCFxCopTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCManagedResourceCompilerTool)
	{
		vs200x_project_vc_managed_resource_compiler_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManagedResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCManifestTool)
	{
		vs200x_project_vc_manifest_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCManifestTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCMIDLTool)
	{
		vs200x_project_vc_midl_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCMIDLTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCPreBuildEventTool)
	{
		vs200x_project_vc_pre_build_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCPreLinkEventTool)
	{
		vs200x_project_vc_pre_link_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPreLinkEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCPostBuildEventTool)
	{
		vs200x_project_vc_post_build_event_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCPostBuildEventTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCResourceCompilerTool)
	{
		vs200x_project_vc_resource_compiler_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCResourceCompilerTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCWebDeploymentTool)
	{
		vs200x_project_vc_web_deployment_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebDeploymentTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCWebServiceProxyGeneratorTool)
	{
		vs200x_project_vc_web_service_proxy_generator_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCWebServiceProxyGeneratorTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCXDCMakeTool)
	{
		vs200x_project_vc_xdc_make_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCXDCMakeTool\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_VCXMLDataGeneratorTool)
	{
		vs200x_project_vc_xml_data_generator_tool(sess, prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCXMLDataGeneratorTool\"/>\n",
			buffer);
	}


	/**********************************************************************
	 * Files section tests
	 **********************************************************************/

	TEST_FIXTURE(FxVsProject, Vs200x_Files_OnNoFiles)
	{
		vs200x_project_files(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Files>\n"
			"\t</Files>\n",
			buffer);
	}

	TEST_FIXTURE(FxVsProject, Vs200x_Files_OnSingleCppFile)
	{
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

	TEST_FIXTURE(FxVsProject, Vs200x_Files_OnUpperDirectory)
	{
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

	TEST_FIXTURE(FxVsProject, Vs200x_Files_OnGroupedCppFile)
	{
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

	TEST_FIXTURE(FxVsProject, Vs200x_Globals)
	{
		vs200x_project_globals(sess, prj, strm);
		CHECK_EQUAL(
			"\t<Globals>\n"
			"\t</Globals>\n"
			"</VisualStudioProject>\n",
			buffer);
	}
}
