/**
 * \file   make_tests.cpp
 * \brief  Automated tests for the makefile generator support functions.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "actions/make/make.h"
#include "base/error.h"
}


struct FxMake
{
	Session  sess;
	Solution sln1;
	Solution sln2;
	Project  prj1;
	Project  prj2;

	FxMake()
	{
		sess = session_create();
		sln1 = AddSolution("MySolution1");
		sln2 = AddSolution("MySolution2");
		prj1 = AddProject("MyProject1");
		prj2 = AddProject("MyProject2");
	}

	~FxMake()
	{
		session_destroy(sess);
		error_clear();
	}

	Solution AddSolution(const char* name)
	{
		Solution sln = solution_create();
		session_add_solution(sess, sln);
		solution_set_name(sln, name);
		solution_set_base_dir(sln, ".");
		return sln;
	}

	Project AddProject(const char* name)
	{
		Project prj = project_create();
		solution_add_project(sln1, prj);
		project_set_name(prj, name);
		project_set_base_dir(prj, ".");
		return prj;
	}
};


SUITE(action)
{
	/**********************************************************************
	 * Makefile naming tests
	 **********************************************************************/

	TEST_FIXTURE(FxMake, GetSolutionMakefile_ReturnsMakefile_OnUniqueLocation)
	{
		solution_set_location(sln1, "MySolution");
		const char* result = make_get_solution_makefile(sln1);
		CHECK_EQUAL("./MySolution/Makefile", result);
	}

	TEST_FIXTURE(FxMake, GetSolutionMakefile_ReturnsDotMake_OnSharedLocation)
	{
		const char* result = make_get_solution_makefile(sln1);
		CHECK_EQUAL("./MySolution1.make", result);
	}

	TEST_FIXTURE(FxMake, GetProjectMakefile_ReturnsMakefile_OnUniqueLocation)
	{
		project_set_location(prj1, "MyProject");
		const char* result = make_get_project_makefile(prj1);
		CHECK_EQUAL("./MyProject/Makefile", result);
	}

	TEST_FIXTURE(FxMake, GetProjectMakefile_ReturnsDotMake_OnSharedWithSolution)
	{
		project_set_location(prj2, "MyProject");
		const char* result = make_get_project_makefile(prj1);
		CHECK_EQUAL("./MyProject1.make", result);
	}

	TEST_FIXTURE(FxMake, GetProjectMakefile_ReturnsDotMake_OnSharedWithProject)
	{
		project_set_location(prj1, "MyProject");
		project_set_location(prj2, "MyProject");
		const char* result = make_get_project_makefile(prj1);
		CHECK_EQUAL("./MyProject/MyProject1.make", result);
	}
}
