/**
 * \file   session_tests.cpp
 * \brief  Automated test for the Session class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
}


#define FAIL_SLN_PARAM  (1)
#define FAIL_PRJ_PARAM  (2)

static int num_solution_calls;
static int num_project_calls;

static int test_solution_okay(Session sess, Solution sln, Stream strm)
{
	sess = NULL; sln = NULL; strm = NULL;
	num_solution_calls++;
	return OKAY;
}

static int test_solution_fail(Session sess, Solution sln, Stream strm)
{
	sess = NULL; sln = NULL; strm = NULL;
	return !OKAY;
}


struct FxSession
{
	Session sess;

	FxSession()
	{
		sess = session_create();
		num_solution_calls = 0;
		num_project_calls = 0;
	}

	~FxSession()
	{
		session_destroy(sess);
	}

	Solution AddSolution()
	{
		Solution sln = solution_create();
		session_add_solution(sess, sln);
		return sln;
	}
};


SUITE(session)
{
	/**********************************************************************
	 * Initial state checks
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Create_ReturnsObject_OnSuccess)
	{
		CHECK(sess != NULL);
	}


	/**********************************************************************
	 * Script execution tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, RunString_ReturnsValue_OnString)
	{
		const char* result = session_run_string(sess, "return 'string value'");
		CHECK_EQUAL("string value", result);
	}

	TEST_FIXTURE(FxSession, RunString_ReturnsValue_OnInteger)
	{
		const char* result = session_run_string(sess, "return 18");
		CHECK_EQUAL("18", result);
	}

	TEST_FIXTURE(FxSession, RunString_ReturnsValue_OnBoolean)
	{
		const char* result = session_run_string(sess, "return true");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxSession, RunFile_ReturnsValue_OnValidFile)
	{
		const char* result = session_run_file(sess, "testing/test_files/true.lua");
		CHECK_EQUAL("true", result);
	}


	/**********************************************************************
	 * Solution containment tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, NumSolutions_ReturnsZero_OnCreate)
	{
		int n = session_num_solutions(sess);
		CHECK(n == 0);
	}

	TEST_FIXTURE(FxSession, NumSolutions_ReturnsOne_OnAddSolution)
	{
		AddSolution();
		int n = session_num_solutions(sess);
		CHECK(n == 1);
	}

	TEST_FIXTURE(FxSession, GetSolution_ReturnsSolution_OnAddSolution)
	{
		Solution sln = AddSolution();
		CHECK(sln == session_get_solution(sess, 0));
	}


	/**********************************************************************
	 * Object enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Enumerate_ReturnsOkay_OnSuccess)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		int result = session_enumerate_objects(sess, sln_funcs, prj_funcs);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsAllSolutionFuncs_OnSolution)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_okay, test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsSolutionFunc_OnEachSolution)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		AddSolution();
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_ReturnsNotOkay_OnSolutionError)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_fail, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		AddSolution();
		int result = session_enumerate_objects(sess, sln_funcs, prj_funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxSession, Enumerate_StopsProcessing_OnSolutionError)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_fail, test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		AddSolution();
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs);
		CHECK(num_solution_calls == 0);
	}


	/**********************************************************************
	 * Unload tests - most unload testing is done elsewhere
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Unload_ReturnsOkay_OnNoProjectInfo)
	{
		int result = session_unload(sess);
		CHECK(result == OKAY);
	}
}

