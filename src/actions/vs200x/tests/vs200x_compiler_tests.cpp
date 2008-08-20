/**
 * \file   vs200x_compiler_tests.cpp
 * \brief  Automated tests for VS200x compiler block processing.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
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
	 * Default settings
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VCCLCompilerTool_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_project_vc_cl_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCLCompilerTool\"\n"
			"\t\t\t\tOptimization=\"0\"\n"
			"\t\t\t\tMinimalRebuild=\"TRUE\"\n"
			"\t\t\t\tBasicRuntimeChecks=\"3\"\n"
			"\t\t\t\tRuntimeLibrary=\"3\"\n"
			"\t\t\t\tRuntimeTypeInfo=\"TRUE\"\n"
			"\t\t\t\tUsePrecompiledHeader=\"2\"\n"
			"\t\t\t\tWarningLevel=\"3\"\n"
			"\t\t\t\tDetect64BitPortabilityProblems=\"TRUE\"\n"
			"\t\t\t\tDebugInformationFormat=\"0\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VCCLCompilerTool_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_project_vc_cl_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCLCompilerTool\"\n"
			"\t\t\t\tOptimization=\"0\"\n"
			"\t\t\t\tMinimalRebuild=\"true\"\n"
			"\t\t\t\tBasicRuntimeChecks=\"3\"\n"
			"\t\t\t\tRuntimeLibrary=\"3\"\n"
			"\t\t\t\tUsePrecompiledHeader=\"0\"\n"
			"\t\t\t\tWarningLevel=\"3\"\n"
			"\t\t\t\tDetect64BitPortabilityProblems=\"true\"\n"
			"\t\t\t\tDebugInformationFormat=\"0\"\n"
			"\t\t\t/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VCCLCompilerTool_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_project_vc_cl_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCLCompilerTool\"\n"
			"\t\t\t\tOptimization=\"0\"\n"
			"\t\t\t\tMinimalRebuild=\"true\"\n"
			"\t\t\t\tBasicRuntimeChecks=\"3\"\n"
			"\t\t\t\tRuntimeLibrary=\"3\"\n"
			"\t\t\t\tUsePrecompiledHeader=\"0\"\n"
			"\t\t\t\tWarningLevel=\"3\"\n"
			"\t\t\t\tDebugInformationFormat=\"0\"\n"
			"\t\t\t/>\n",
			buffer);
	}


	/**********************************************************************
	 * Defines tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, VCCLCompilerTool_WithDefines)
	{
		env_set_action("vs2002");
		const char* defines[] = { "DEFINE0", "DEFINE1", NULL };
		SetConfigField(prj, BlockDefines, defines);
		vs200x_project_vc_cl_compiler_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCCLCompilerTool\"\n"
			"\t\t\t\tOptimization=\"0\"\n"
			"\t\t\t\tPreprocessorDefinitions=\"DEFINE0;DEFINE1\"\n"
			"\t\t\t\tMinimalRebuild=\"TRUE\"\n"
			"\t\t\t\tBasicRuntimeChecks=\"3\"\n"
			"\t\t\t\tRuntimeLibrary=\"3\"\n"
			"\t\t\t\tRuntimeTypeInfo=\"TRUE\"\n"
			"\t\t\t\tUsePrecompiledHeader=\"2\"\n"
			"\t\t\t\tWarningLevel=\"3\"\n"
			"\t\t\t\tDetect64BitPortabilityProblems=\"TRUE\"\n"
			"\t\t\t\tDebugInformationFormat=\"0\"/>\n",
			buffer);
	}
}
