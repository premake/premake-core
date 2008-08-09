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
		prj = project_create();
	}

	~FxProject()
	{
		project_destroy(prj);
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

	TEST_FIXTURE(FxProject, GetFilename_ReturnsFullPath_OnNoLocation)
	{
		project_set_name(prj, "MyProject");
		project_set_base_dir(prj, "/BaseDir");
		const char* filename = project_get_filename(prj, NULL, ".xyz");
		CHECK_EQUAL("/BaseDir/MyProject.xyz", filename);
	}

	TEST_FIXTURE(FxProject, GetFilename_ReturnsFullPath_OnLocation)
	{
		project_set_name(prj, "MyProject");
		project_set_base_dir(prj, "/BaseDir");
		project_set_location(prj, "Location");
		const char* filename = project_get_filename(prj, NULL, ".xyz");
		CHECK_EQUAL("/BaseDir/Location/MyProject.xyz", filename);
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

	TEST_FIXTURE(FxProject, GetSolution_ReturnsNull_OnStartup)
	{
		Solution result = project_get_solution(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, SetSolution_CanRoundtrip)
	{
		project_set_solution(prj, sln);
		CHECK(sln == project_get_solution(prj));
	}

}


