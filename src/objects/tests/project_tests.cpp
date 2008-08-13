/**
 * \file   project_tests.cpp
 * \brief  Automated tests for the project objects API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "objects/solution.h"
#include "objects/objects_internal.h"
#include "base/env.h"
}


struct FxProject
{
	Solution sln;
	Project prj;

	FxProject()
	{
		sln = solution_create();
		solution_set_name(sln, "MySolution");
		solution_set_location(sln, "/BaseDir/MySolution");

		prj = project_create();
		solution_add_project(sln, prj);
		project_set_name(prj, "MyProject");
	}

	~FxProject()
	{
		solution_destroy(sln);
	}
};


SUITE(project)
{
	TEST_FIXTURE(FxProject, Create_ReturnsObject_OnSuccess)
	{
		CHECK(prj != NULL);
	}


	/**********************************************************************
	 * Filename tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetFilenameRel_ReturnsCorrectPath_OnSameDir)
	{
		project_set_location(prj, "/BaseDir/MySolution");
		const char* filename = project_get_filename_relative(prj, NULL, ".xyz");
		CHECK_EQUAL("MyProject.xyz", filename);
	}

	TEST_FIXTURE(FxProject, GetFilenameRel_ReturnsCorrectPath_OnDifferentDir)
	{
		project_set_location(prj, "/BaseDir/MyProject");
		const char* filename = project_get_filename_relative(prj, NULL, ".xyz");
		CHECK_EQUAL("../MyProject/MyProject.xyz", filename);
	}



	/**********************************************************************
	 * Language tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetLanguage_ReturnsSolutionLanguage_OnNoProjectLanguage)
	{
		project_set_solution(prj, sln);
		solution_set_language(sln, "c#");
		const char* result = project_get_language(prj);
		CHECK_EQUAL("c#", result);
	}


	/**********************************************************************
	 * Output file tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetOutFile_ReturnsProjectName_OnNoTargetAndNotWindows)
	{
		env_set_os(MacOSX);
		project_set_name(prj, "MyProject");
		const char* result = project_get_outfile(prj);
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FxProject, GetOutFile_AddsExe_OnNoTargetAndWindows)
	{
		env_set_os(Windows);
		project_set_name(prj, "MyProject");
		const char* result = project_get_outfile(prj);
		CHECK_EQUAL("MyProject.exe", result);
	}


	/**********************************************************************
	 * Solution tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, SetSolution_CanRoundtrip)
	{
		CHECK(sln == project_get_solution(prj));
	}

}


