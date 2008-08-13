/**
 * \file   solution_tests.cpp
 * \brief  Automated tests for the Solution class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "objects/solution.h"
#include "objects/objects_internal.h"
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
