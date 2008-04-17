/**
 * \file   vs2002_solution_tests.cpp
 * \brief  Automated tests for VS2002 solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}

#include "vs200x_tests.h"


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_Signature_IsCorrect)
	{
		session_set_action(sess, "vs2002");
		vs2002_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"Microsoft Visual Studio Solution File, Format Version 7.00\r\n",
			buffer);
	}


	/**********************************************************************
	 * Project entry tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_ProjectEntry_UsesRelativePath)
	{
		vs2002_solution_projects(sess, sln, strm);			
		CHECK_EQUAL(
			"Project(\"{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}\") = \"MyProject\", \"ProjectFolder\\MyProject.vcproj\", \"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"EndProject\n",
			buffer);
	}


	/**********************************************************************
	 * Solution configuration tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_SolutionConfiguration_IsCorrect)
	{
		vs2002_solution_configuration(sess, sln, strm);
		CHECK_EQUAL(
			"Global\n"
			"\tGlobalSection(SolutionConfiguration) = preSolution\n"
			"\t\tConfigName.0 = Debug\n"
			"\t\tConfigName.1 = Release\n"
			"\tEndGlobalSection\n",
			buffer);
	}


	/**********************************************************************
	 * Project dependencies tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_ProjectDependencies_IsCorrect)
	{
		vs2002_solution_dependencies(sess, sln, strm);
		CHECK_EQUAL(
			"\tGlobalSection(ProjectDependencies) = postSolution\n"
			"\tEndGlobalSection\n",
			buffer);
	}


	/**********************************************************************
	 * Project configuration tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_ProjectConfiguration_IsCorrect)
	{
		vs2002_solution_project_configuration(sess, sln, strm);
		CHECK_EQUAL(
			"\tGlobalSection(ProjectConfiguration) = postSolution\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Debug.ActiveCfg = Debug|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Debug.Build.0 = Debug|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Release.ActiveCfg = Release|Win32\n"
			"\t\t{AE2461B7-236F-4278-81D3-F0D476F9A4C0}.Release.Build.0 = Release|Win32\n"
			"\tEndGlobalSection\n",
			buffer);
	}


	/**********************************************************************
	 * Solution extensibility tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2002_Extensibility_IsCorrect)
	{
		vs2002_solution_extensibility(sess, sln, strm);
		CHECK_EQUAL(
			"\tGlobalSection(ExtensibilityGlobals) = postSolution\n"
			"\tEndGlobalSection\n"
			"\tGlobalSection(ExtensibilityAddIns) = postSolution\n"
			"\tEndGlobalSection\n"
			"EndGlobal\n",
			buffer);
	}

}
