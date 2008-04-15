/**
 * \file   fn_solution_tests.cpp
 * \brief  Automated tests for the solution() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
}

struct FnSolution1
{
	Session sess;

	FnSolution1()
	{
		sess = session_create();
	}

	~FnSolution1()
	{
		session_destroy(sess);
	}
};

struct FnSolution2 : FnSolution1
{
	FnSolution2()
	{
		session_run_string(sess, "sln = solution('MySolution');");
	}

	~FnSolution2()
	{
	}
};


SUITE(engine)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FnSolution1, Solution_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (solution ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution1, Solution_ReturnsNil_OnNoActiveSolution)
	{
		const char* result = session_run_string(sess,
			"return (solution() == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution1, Solutions_Exists_OnStartup)
	{
		const char* result = session_run_string(sess,
			"return #_SOLUTIONS");
		CHECK_EQUAL("0", result);
	}


	/**************************************************************************
	 * Object creation tests
	 **************************************************************************/

	TEST_FIXTURE(FnSolution2, Solution_ReturnsNewObject_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (sln ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_ReturnsObject_OnActiveSolution)
	{
		const char* result = session_run_string(sess,
			"return (sln == solution())");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_AddsToKeyList_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (sln == _SOLUTIONS['MySolution']);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_AddsToIndexList_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (sln == _SOLUTIONS[1]);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_IncrementsTableSize_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return #_SOLUTIONS;");
		CHECK_EQUAL("1", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_ReturnsSameObject_OnExistingName)
	{
		const char* result = session_run_string(sess,
			"sln1 = solution('SecondSolution');"
			"return (sln == solution('MySolution'))");
		CHECK_EQUAL("true", result);
	}


	/**************************************************************************
	 * Initial object state tests
	 **************************************************************************/

	TEST_FIXTURE(FnSolution2, Solution_SetsName)
	{
		const char* result = session_run_string(sess, 
			"return sln.name");
		CHECK_EQUAL("MySolution", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_SetsBaseDir)
	{
		const char* result = session_run_string(sess,
			"return sln.basedir");
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FnSolution2, Solution_HasEmptyProjectsList)
	{
		const char* result = session_run_string(sess,
			"return #sln.projects");
		CHECK_EQUAL("0", result);
	}
}
