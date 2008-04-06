/**
 * \file   make_tests.cpp
 * \brief  Automated tests for the makefile generator support functions.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/engine.h"
#include "action/make/make.h"
}


struct FxMake
{
	Session  sess;
	Solution sln1;
	Solution sln2;

	FxMake()
	{
		sess = session_create();
		sln1 = AddSolution("MySolution1");
		sln2 = AddSolution("MySolution2");
	}

	~FxMake()
	{
		session_destroy(sess);
	}

	Solution AddSolution(const char* name)
	{
		Solution sln = solution_create();
		session_add_solution(sess, sln);
		solution_set_name(sln, name);
		solution_set_base_dir(sln, ".");
		return sln;
	}
};


SUITE(action)
{
	TEST_FIXTURE(FxMake, GetSolutionMakefile_ReturnsMakefile_OnUniqueLocation)
	{
		solution_set_location(sln1, "MySolution");
		const char* result = make_get_solution_makefile(sess, sln1);
		CHECK_EQUAL("./MySolution/Makefile", result);
	}

	TEST_FIXTURE(FxMake, GetSolutionMakefile_ReturnsDotMake_OnSharedLocation)
	{
		const char* result = make_get_solution_makefile(sess, sln1);
		CHECK_EQUAL("./MySolution1.make", result);
	}
}
