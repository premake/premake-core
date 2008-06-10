/**
 * \file   project_tests.cpp
 * \brief  Automated tests for the project objects API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
#include "project/project.h"
#include "project/project_internal.h"
#include "platform/platform.h"
}


/**
 * \brief   Run the project API automated tests.
 * \returns OKAY if all tests completed successfully.
 */
int project_tests()
{
	int status = tests_run_suite("fields");
	if (status == OKAY)  status = tests_run_suite("project");
	return status;
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
	 * Name tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetName_ReturnsNull_OnStartup)
	{
		const char* name = project_get_name(prj);
		CHECK(name == NULL);
	}

	TEST_FIXTURE(FxProject, SetName_CanRoundtrip)
	{
		project_set_name(prj, "MyProject");
		const char* name = project_get_name(prj);
		CHECK_EQUAL("MyProject", name);
	}


	/**********************************************************************
	 * Base directory tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetBaseDir_ReturnsNull_OnStartup)
	{
		const char* result = project_get_base_dir(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, SetBaseDir_CanRoundtrip)
	{
		project_set_base_dir(prj, "BaseDir");
		const char* result = project_get_base_dir(prj);
		CHECK_EQUAL("BaseDir", result);
	}


	/**********************************************************************
	 * Configuration filter tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, ConfigurationFilter_ReturnsNull_OnStartup)
	{
		const char* result = project_get_configuration_filter(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, ConfigurationFilter_CanRoundtrip)
	{
		project_set_configuration_filter(prj, "Debug");
		const char* result = project_get_configuration_filter(prj);
		CHECK_EQUAL("Debug", result);
	}


	/**********************************************************************
	 * GUID tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetGuid_ReturnsNull_OnStartup)
	{
		const char* result = project_get_guid(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, SetGuid_CanRoundtrip)
	{
		project_set_guid(prj, "AE2461B7-236F-4278-81D3-F0D476F9A4C0");
		const char* result = project_get_guid(prj);
		CHECK_EQUAL("AE2461B7-236F-4278-81D3-F0D476F9A4C0", result);
	}


	/**********************************************************************
	 * Language tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetLanguage_ReturnsNull_OnStartup)
	{
		const char* result = project_get_language(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, SetLanguage_CanRoundtrip)
	{
		project_set_language(prj, "c++");
		const char* result = project_get_language(prj);
		CHECK_EQUAL("c++", result);
	}

	TEST_FIXTURE(FxProject, GetLanguage_ReturnsSolutionLanguage_OnNoProjectLanguage)
	{
		project_set_solution(prj, sln);
		solution_set_language(sln, "c#");
		const char* result = project_get_language(prj);
		CHECK_EQUAL("c#", result);
	}


	/**********************************************************************
	 * Location tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetLocation_ReturnsNull_OnStartup)
	{
		const char* result = project_get_location(prj);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxProject, SetLocation_CanRoundtrip)
	{
		project_set_location(prj, "Location");
		const char* result = project_get_location(prj);
		CHECK_EQUAL("Location", result);
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
	 * Output file tests
	 **********************************************************************/

	TEST_FIXTURE(FxProject, GetOutFile_ReturnsProjectName_OnNoTargetAndNotWindows)
	{
		platform_set(MacOSX);
		project_set_name(prj, "MyProject");
		const char* result = project_get_outfile(prj);
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FxProject, GetOutFile_AddsExe_OnNoTargetAndWindows)
	{
		platform_set(Windows);
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


