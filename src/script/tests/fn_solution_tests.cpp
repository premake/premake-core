/**
 * \file   fn_solution_tests.cpp
 * \brief  Automated tests for the solution() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


struct FnSolution : FxScript
{
	FnSolution()
	{
		script_run_string(script, "sln = solution('MySolution');");
	}
};


SUITE(script)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FxScript, Solution_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (solution ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Solution_ReturnsNil_OnNoActiveSolution)
	{
		const char* result = script_run_string(script,
			"return (solution() == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Solutions_Exists_OnStartup)
	{
		const char* result = script_run_string(script,
			"return #_SOLUTIONS");
		CHECK_EQUAL("0", result);
	}


	/**************************************************************************
	 * Object creation tests
	 **************************************************************************/

	TEST_FIXTURE(FnSolution, Solution_ReturnsNewObject_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (sln ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution, Solution_ReturnsObject_OnActiveSolution)
	{
		const char* result = script_run_string(script,
			"return (sln == solution())");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution, Solution_AddsToKeyList_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (sln == _SOLUTIONS['MySolution']);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution, Solution_AddsToIndexList_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (sln == _SOLUTIONS[1]);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution, Solution_IncrementsTableSize_OnNewName)
	{
		const char* result = script_run_string(script,
			"return #_SOLUTIONS;");
		CHECK_EQUAL("1", result);
	}

	TEST_FIXTURE(FnSolution, Solution_ReturnsSameObject_OnExistingName)
	{
		const char* result = script_run_string(script,
			"sln1 = solution('SecondSolution');"
			"return (sln == solution('MySolution'))");
		CHECK_EQUAL("true", result);
	}


	/**************************************************************************
	 * Initial object state tests
	 **************************************************************************/

	TEST_FIXTURE(FnSolution, Solution_SetsName)
	{
		const char* result = script_run_string(script, 
			"return sln.name");
		CHECK_EQUAL("MySolution", result);
	}

	TEST_FIXTURE(FnSolution, Solution_SetsBaseDir)
	{
		const char* result = script_run_string(script,
			"return sln.basedir");
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FnSolution, Solution_HasEmptyProjectsList)
	{
		const char* result = script_run_string(script,
			"return #sln.projects");
		CHECK_EQUAL("0", result);
	}
}
