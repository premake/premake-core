/**
 * \file   unload_tests.cpp
 * \brief  Automated tests for project object enumeration from the script environment.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/internals.h"
}

/* mock interface to object loaders */

static int num_solution_calls;
static int num_project_calls;

static int stub_solution_func(Session sess, lua_State* L, Solution sln)
{
	sess = NULL; L = NULL; sln = NULL;
	num_solution_calls++;
	return OKAY;
}

static int stub_solution_fail_func(Session sess, lua_State* L, Solution sln)
{
	sess = NULL; L = NULL; sln = NULL;
	num_solution_calls++;
	return !OKAY;
}

static int stub_project_func(Session sess, lua_State* L, Project prj)
{
	sess = NULL; L = NULL; prj = NULL;
	num_project_calls++;
	return OKAY;
}

static int stub_project_fail_func(Session sess, lua_State* L, Project prj)
{
	sess = NULL; L = NULL; prj = NULL;
	num_project_calls++;
	return !OKAY;
}


struct FxUnload
{
	Session    sess;
	lua_State*  L;
	UnloadFuncs funcs;

	FxUnload()
	{
		sess = session_create();
		L = session_get_lua_state(sess);
		funcs.unload_solution = stub_solution_func;
		funcs.unload_project  = stub_project_func;
		num_solution_calls = 0;
		num_project_calls = 0;
	}

	~FxUnload()
	{
		session_destroy(sess);
	}
};


struct FxUnload2 : FxUnload
{
	FxUnload2()
	{
		session_run_string(sess,
			"solution 'MySolution';"
			"  project 'MyProject';"
			"  project 'MyProject2';"
			"solution 'MySolution2';");
	}

	~FxUnload2()
	{
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnload, Unload_ReturnsOkay_OnEmptySession)
	{
		int result = unload_all(sess, L, &funcs);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxUnload, Unload_ReturnsEmptySession_OnEmptySession)
	{
		unload_all(sess, L, &funcs);
		int n = session_num_solutions(sess);
		CHECK(n == 0);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsOkay_OnNonEmptySession)
	{
		int result = unload_all(sess, L, &funcs);
		CHECK(result == OKAY);
	}


	/**********************************************************************
	 * Solution enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxUnload2, Unload_AddsSolutions_OnNonEmptySession)
	{
		unload_all(sess, L, &funcs);
		int n = session_num_solutions(sess);
		CHECK(n == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_CallsSolutionFunc_OnEachSolution)
	{
		unload_all(sess, L, &funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsNotOkay_OnSolutionFailure)
	{
		funcs.unload_solution = stub_solution_fail_func;
		int result = unload_all(sess, L, &funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxUnload2, Unload_AbortsSolutionLoop_OnNotOkay)
	{
		funcs.unload_solution = stub_solution_fail_func;
		unload_all(sess, L, &funcs);
		CHECK(num_solution_calls == 1);
	}


	/**********************************************************************
	 * Project enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxUnload2, Unload_AddsProjects_OnNonEmptySession)
	{
		unload_all(sess, L, &funcs);
		Solution sln = session_get_solution(sess, 0);
		int n = solution_num_projects(sln);
		CHECK(n == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_CallsProjectFunc_OnEachProject)
	{
		unload_all(sess, L, &funcs);
		CHECK(num_project_calls == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsNotOkay_OnProjectFailure)
	{
		funcs.unload_project = stub_project_fail_func;
		int result = unload_all(sess, L, &funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxUnload2, Unload_AbortsProjectLoop_OnNotOkay)
	{
		funcs.unload_project = stub_project_fail_func;
		unload_all(sess, L, &funcs);
		CHECK(num_project_calls == 1);
	}

}
