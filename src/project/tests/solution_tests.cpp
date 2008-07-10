/**
 * \file   solution_tests.cpp
 * \brief  Automated tests for the Solution class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
#include "project/project.h"
#include "project/project_internal.h"
#include "base/strings.h"
}


struct FxSolution
{
	Solution sln;

	FxSolution()
	{
		sln = solution_create();
	}

	~FxSolution()
	{
		if (sln)
			solution_destroy(sln);
	}
};


SUITE(project)
{
	TEST_FIXTURE(FxSolution, Create_ReturnsObject_OnSuccess)
	{
		CHECK(sln != NULL);
	}


	/**********************************************************************
	 * Name tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, GetName_ReturnsNull_OnStartup)
	{
		const char* name = solution_get_name(sln);
		CHECK(name == NULL);
	}

	TEST_FIXTURE(FxSolution, SetName_CanRoundtrip)
	{
		solution_set_name(sln, "MySolution");
		const char* name = solution_get_name(sln);
		CHECK_EQUAL("MySolution", name);
	}


	/**********************************************************************
	 * Base directory tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, GetBaseDir_ReturnsNull_OnStartup)
	{
		const char* result = solution_get_base_dir(sln);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxSolution, SetBaseDir_CanRoundtrip)
	{
		solution_set_base_dir(sln, "BaseDir");
		const char* result = solution_get_base_dir(sln);
		CHECK_EQUAL("BaseDir", result);
	}


	/**********************************************************************
	 * Configuration containment tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, NumConfigs_IsZero_OnStartup)
	{
		int result = solution_num_configs(sln);
		CHECK(result == 0);
	}

	TEST_FIXTURE(FxSolution, AddConfig_IncrementsNumConfigs)
	{
		solution_add_config(sln, "Debug");
		int result = solution_num_configs(sln);
		CHECK(result == 1);
	}

	TEST_FIXTURE(FxSolution, AddConfig_CanRoundtrip)
	{
		solution_add_config(sln, "Debug");
		const char* result = solution_get_config(sln, 0);
		CHECK_EQUAL("Debug", result);
	}

	TEST_FIXTURE(FxSolution, GetConfigs_ReturnsEmptyList_OnStartup)
	{
		Strings result = solution_get_configs(sln);
		CHECK(strings_size(result) == 0);
	}

	TEST_FIXTURE(FxSolution, GetConfigs_ReturnsList_OnItemsAdded)
	{
		solution_add_config(sln, "Debug");
		Strings result = solution_get_configs(sln);
		CHECK_EQUAL("Debug", strings_item(result, 0));
	}


	/**********************************************************************
	 * Language tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, GetLanguage_ReturnsNull_OnStartup)
	{
		const char* result = solution_get_language(sln);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxSolution, SetLanguage_CanRoundtrip)
	{
		solution_set_language(sln, "c++");
		const char* result = solution_get_language(sln);
		CHECK_EQUAL("c++", result);
	}


	/**********************************************************************
	 * Location tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, GetLocation_ReturnsNull_OnStartup)
	{
		const char* result = solution_get_location(sln);
		CHECK(result == NULL);
	}

	TEST_FIXTURE(FxSolution, SetLocation_CanRoundtrip)
	{
		solution_set_location(sln, "Location");
		const char* result = solution_get_location(sln);
		CHECK_EQUAL("Location", result);
	}


	/**********************************************************************
	 * Filename tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, GetFilename_ReturnsFullPath_OnNoLocation)
	{
		solution_set_name(sln, "MySolution");
		solution_set_base_dir(sln, "/BaseDir");
		const char* filename = solution_get_filename(sln, NULL, ".xyz");
		CHECK_EQUAL("/BaseDir/MySolution.xyz", filename);
	}

	TEST_FIXTURE(FxSolution, GetFilename_ReturnsFullPath_OnLocation)
	{
		solution_set_name(sln, "MySolution");
		solution_set_base_dir(sln, "/BaseDir");
		solution_set_location(sln, "Location");
		const char* filename = solution_get_filename(sln, NULL, ".xyz");
		CHECK_EQUAL("/BaseDir/Location/MySolution.xyz", filename);
	}


	/**********************************************************************
	 * Project containment tests
	 **********************************************************************/

	TEST_FIXTURE(FxSolution, NumProjects_IsZero_OnStartup)
	{
		int result = solution_num_projects(sln);
		CHECK(result == 0);
	}

	TEST_FIXTURE(FxSolution, AddProject_IncrementsNumProjects)
	{
		Project prj = project_create();
		solution_add_project(sln, prj);
		int result = solution_num_projects(sln);
		CHECK(result == 1);
	}

	TEST_FIXTURE(FxSolution, AddProject_CanRoundtrip)
	{
		Project prj = project_create();
		solution_add_project(sln, prj);
		Project result = solution_get_project(sln, 0);
		CHECK(prj == result);
	}

	TEST_FIXTURE(FxSolution, AddProject_SetsProjectSolution)
	{
		Project prj = project_create();
		solution_add_project(sln, prj);
		CHECK(sln == project_get_solution(prj));
	}
}
