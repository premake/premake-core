/**
 * \file   vs2005_solution_tests.cpp
 * \brief  Automated tests for VS2005 solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs2005_Signature_IsCorrect)
	{
		vs2005_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277\r\n"
			"Microsoft Visual Studio Solution File, Format Version 9.00\r\n"
			"# Visual Studio 2005\r\n",
			buffer);
	}


	/**********************************************************************
	 * Solution Configuration Platforms tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Platforms_IsCorrect)
	{
		vs2005_solution_platforms(sess, sln, strm);
		CHECK_EQUAL(
			"Global\n"
			"\tGlobalSection(SolutionConfigurationPlatforms) = preSolution\n"
			"\t\tDebug|Win32 = Debug|Win32\n"
			"\t\tRelease|Win32 = Release|Win32\n"
			"\tEndGlobalSection\n",
			buffer);
	}


	/**********************************************************************
	 * Project Configuration Platforms tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, ProjectPlatforms_IsCorrect)
	{
		vs2005_solution_project_platforms(sess, sln, strm);
		CHECK_EQUAL(
			"\tGlobalSection(ProjectConfigurationPlatforms) = postSolution\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Debug|Win32.ActiveCfg = Debug|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Debug|Win32.Build.0 = Debug|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Release|Win32.ActiveCfg = Release|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Release|Win32.Build.0 = Release|Win32\n"
			"\tEndGlobalSection\n",
			buffer);
	}


	/**********************************************************************
	 * Solution Project tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Properties_IsCorrect)
	{
		vs2005_solution_properties(sess, sln, strm);
		CHECK_EQUAL(
			"\tGlobalSection(SolutionProperties) = preSolution\n"
			"\t\tHideSolutionNode = FALSE\n"
			"\tEndGlobalSection\n"
			"EndGlobal\n",
			buffer);
	}
}
