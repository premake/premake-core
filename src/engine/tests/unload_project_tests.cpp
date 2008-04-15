/**
 * \file   unload_project_tests.cpp
 * \brief  Automated tests for project object unloading from the script environment.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/internals.h"
}


struct FxUnloadProject
{
	Session    sess;
	lua_State* L;
	Project    prj;

	FxUnloadProject()
	{
		sess = session_create();
		L = session_get_lua_state(sess);
		prj = project_create();

		session_run_string(sess,
			"solution('MySolution');"
			"prj = project('MyProject');"
			"  guid '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"return prj");
	}

	~FxUnloadProject()
	{
		project_destroy(prj);
		session_destroy(sess);
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsName)
	{
		unload_project(sess, L, prj);
		const char* result = project_get_name(prj);
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsBaseDir)
	{
		unload_project(sess, L, prj);
		const char* result = project_get_base_dir(prj);
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsGuid)
	{
		unload_project(sess, L, prj);
		const char* result = project_get_guid(prj);
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}
}

