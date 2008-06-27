/**
 * \file   unload_solution_tests.cpp
 * \brief  Automated tests for solution object unloading from the script environment.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "script/script_internal.h"
}


struct FxUnloadSolution
{
	Script     script;
	lua_State* L;
	Solution   sln;

	FxUnloadSolution()
	{
		script = script_create();
		L = script_get_lua(script);

		sln = solution_create();

		script_run_string(script,
			"sln = solution('MySolution');"
			"  configurations { 'Debug', 'Release' };"
			"return sln");
	}

	~FxUnloadSolution()
	{
		solution_destroy(sln);
		script_destroy(script);
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnloadSolution, UnloadSolution_SetsName)
	{
		unload_solution(L, sln);
		const char* result = solution_get_name(sln);
		CHECK_EQUAL("MySolution", result);
	}

	TEST_FIXTURE(FxUnloadSolution, UnloadSolution_SetsBaseDir)
	{
		unload_solution(L, sln);
		const char* result = solution_get_base_dir(sln);
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FxUnloadSolution, UnloadSolution_SetsConfigurations)
	{
		unload_solution(L, sln);
		CHECK(solution_num_configs(sln) == 2);
		CHECK_EQUAL("Debug", solution_get_config(sln, 0));
		CHECK_EQUAL("Release", solution_get_config(sln, 1));
	}
}

