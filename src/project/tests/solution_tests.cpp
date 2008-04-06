/**
 * \file   solution_tests.cpp
 * \brief  Automated tests for the Solution class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
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
}
