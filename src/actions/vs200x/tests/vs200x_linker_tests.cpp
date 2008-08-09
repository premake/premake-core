/**
 * \file   vs200x_linker_tests.cpp
 * \brief  Automated tests for VS200x linker block processing.
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

	TEST_FIXTURE(FxAction, VCLinkerTool_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_project_vc_linker_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCLinkerTool\"\n"
			"\t\t\t\tLinkIncremental=\"2\"\n"
			"\t\t\t\tGenerateDebugInformation=\"TRUE\"\n"
			"\t\t\t\tSubSystem=\"1\"\n"
			"\t\t\t\tEntryPointSymbol=\"mainCRTStartup\"\n"
			"\t\t\t\tTargetMachine=\"1\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VCLinkerTool_Defaults_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_project_vc_linker_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCLinkerTool\"\n"
			"\t\t\t\tLinkIncremental=\"2\"\n"
			"\t\t\t\tGenerateDebugInformation=\"TRUE\"\n"
			"\t\t\t\tSubSystem=\"1\"\n"
			"\t\t\t\tEntryPointSymbol=\"mainCRTStartup\"\n"
			"\t\t\t\tTargetMachine=\"1\"/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VCLinkerTool_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_project_vc_linker_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCLinkerTool\"\n"
			"\t\t\t\tLinkIncremental=\"2\"\n"
			"\t\t\t\tGenerateDebugInformation=\"true\"\n"
			"\t\t\t\tSubSystem=\"1\"\n"
			"\t\t\t\tEntryPointSymbol=\"mainCRTStartup\"\n"
			"\t\t\t\tTargetMachine=\"1\"\n"
			"\t\t\t/>\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, VCLinkerTool_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_project_vc_linker_tool(prj, strm);
		CHECK_EQUAL(
			"\t\t\t<Tool\n"
			"\t\t\t\tName=\"VCLinkerTool\"\n"
			"\t\t\t\tLinkIncremental=\"2\"\n"
			"\t\t\t\tGenerateDebugInformation=\"true\"\n"
			"\t\t\t\tSubSystem=\"1\"\n"
			"\t\t\t\tEntryPointSymbol=\"mainCRTStartup\"\n"
			"\t\t\t\tTargetMachine=\"1\"\n"
			"\t\t\t/>\n",
			buffer);
	}
}
