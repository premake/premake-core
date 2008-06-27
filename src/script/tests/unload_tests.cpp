/**
 * \file   unload_tests.cpp
 * \brief  Automated tests for project object enumeration from the script environment.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "script/script_internal.h"
}

/* mock interface to object loaders */

static int num_solution_calls;
static int num_project_calls;
static int num_block_calls;

static int stub_solution_func(lua_State* L, Solution sln)
{
	UNUSED(L);  UNUSED(sln);
	num_solution_calls++;
	return OKAY;
}

static int stub_solution_fail_func(lua_State* L, Solution sln)
{
	UNUSED(L);  UNUSED(sln);
	num_solution_calls++;
	return !OKAY;
}

static int stub_project_func(lua_State* L, Project prj)
{
	UNUSED(L);  UNUSED(prj);
	num_project_calls++;
	return OKAY;
}

static int stub_project_fail_func(lua_State* L, Project prj)
{
	UNUSED(L);  UNUSED(prj);
	num_project_calls++;
	return !OKAY;
}

static int stub_block_func(lua_State* L, Block blk)
{
	UNUSED(L);  UNUSED(blk);
	num_block_calls++;
	return OKAY;
}

static int stub_block_fail_func(lua_State* L, Block blk)
{
	UNUSED(L);  UNUSED(blk);
	num_block_calls++;
	return !OKAY;
}


struct FxUnload
{
	Script      script;
	lua_State*  L;
	Array       slns;
	UnloadFuncs funcs;

	FxUnload()
	{
		script = script_create();
		L = script_get_lua(script);
	
		slns = array_create();

		funcs.unload_solution = stub_solution_func;
		funcs.unload_project  = stub_project_func;
		funcs.unload_block    = stub_block_func;
		num_solution_calls = 0;
		num_project_calls = 0;
		num_block_calls = 0;
	}

	~FxUnload()
	{
		array_destroy(slns);
		script_destroy(script);
	}
};


struct FxUnload2 : FxUnload
{
	FxUnload2()
	{
		script_run_string(script,
			"solution 'MySolution';"
			"  configurations{'Debug','Release'};"
			"  project 'MyProject';"
			"  project 'MyProject2';"
			"    configuration 'Debug';"
			"solution 'MySolution2';");
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnload, Unload_ReturnsOkay_OnEmptySession)
	{
		int result = unload_all(L, slns, &funcs);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxUnload, Unload_ReturnsEmptySession_OnEmptySession)
	{
		unload_all(L, slns, &funcs);
		int n = array_size(slns);
		CHECK(n == 0);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsOkay_OnNonEmptySession)
	{
		int result = unload_all(L, slns, &funcs);
		CHECK(result == OKAY);
	}


	/**********************************************************************
	 * Solution enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxUnload2, Unload_AddsSolutions_OnNonEmptySession)
	{
		unload_all(L, slns, &funcs);
		int n = array_size(slns);
		CHECK(n == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_CallsSolutionFunc_OnEachSolution)
	{
		unload_all(L, slns, &funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsNotOkay_OnSolutionFailure)
	{
		funcs.unload_solution = stub_solution_fail_func;
		int result = unload_all(L, slns, &funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxUnload2, Unload_AbortsSolutionLoop_OnNotOkay)
	{
		funcs.unload_solution = stub_solution_fail_func;
		unload_all(L, slns, &funcs);
		CHECK(num_solution_calls == 1);
	}


	/**********************************************************************
	 * Project enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxUnload2, Unload_AddsProjects_OnNonEmptySession)
	{
		unload_all(L, slns, &funcs);
		Solution sln = (Solution)array_item(slns, 0);
		int n = solution_num_projects(sln);
		CHECK(n == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_CallsProjectFunc_OnEachProject)
	{
		unload_all(L, slns, &funcs);
		CHECK(num_project_calls == 2);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsNotOkay_OnProjectFailure)
	{
		funcs.unload_project = stub_project_fail_func;
		int result = unload_all(L, slns, &funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxUnload2, Unload_AbortsProjectLoop_OnNotOkay)
	{
		funcs.unload_project = stub_project_fail_func;
		unload_all(L, slns, &funcs);
		CHECK(num_project_calls == 1);
	}


	/**********************************************************************
	 * Configuration block enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxUnload2, Unload_AddsBlocks_OnNonEmptySession)
	{
		unload_all(L, slns, &funcs);
		Solution sln = (Solution)array_item(slns, 0);
		int n = solution_num_blocks(sln);
		CHECK(n == 1);
	}

	TEST_FIXTURE(FxUnload2, Unload_CallsBlockFunc_OnEachConfig)
	{
		unload_all(L, slns, &funcs);
		CHECK(num_block_calls == 5);
	}

	TEST_FIXTURE(FxUnload2, Unload_ReturnsNotOkay_OnBlockFailure)
	{
		funcs.unload_block = stub_block_fail_func;
		int result = unload_all(L, slns, &funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxUnload2, Unload_AbortsBlockLoop_OnNotOkay)
	{
		funcs.unload_block = stub_block_fail_func;
		unload_all(L, slns, &funcs);
		CHECK(num_block_calls == 1);
	}

}
