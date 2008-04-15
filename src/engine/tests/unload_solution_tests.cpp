/**
 * \file   unload_solution_tests.cpp
 * \brief  Automated tests for solution object unloading from the script environment.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/internals.h"
}


struct FxUnloadSolution
{
	Session    sess;
	lua_State* L;
	Solution   sln;

	FxUnloadSolution()
	{
		sess = session_create();
		L = session_get_lua_state(sess);
		sln = solution_create();

		session_run_string(sess, 
			"sln = solution('MySolution');"
			"return sln");
	}

	~FxUnloadSolution()
	{
		solution_destroy(sln);
		session_destroy(sess);
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnloadSolution, UnloadSolution_SetsName)
	{
		unload_solution(sess, L, sln);
		const char* result = solution_get_name(sln);
		CHECK_EQUAL("MySolution", result);
	}

	TEST_FIXTURE(FxUnloadSolution, UnloadSolution_SetsBaseDir)
	{
		unload_solution(sess, L, sln);
		const char* result = solution_get_base_dir(sln);
		CHECK_EQUAL("(string)", result);
	}
}

