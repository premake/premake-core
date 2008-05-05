/**
 * \file   unload_project_tests.cpp
 * \brief  Automated tests for project object unloading from the script environment.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "script/script_internal.h"
}


struct FxUnloadProject
{
	Script     script;
	lua_State* L;
	Project    prj;

	FxUnloadProject()
	{
		script = script_create();
		L = script_get_lua(script);

		prj = project_create();

		script_run_string(script,
			"solution('MySolution');"
			"prj = project('MyProject');"
			"  guid '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"  language 'c++';"
			"return prj");
	}

	~FxUnloadProject()
	{
		project_destroy(prj);
		script_destroy(script);
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsName)
	{
		unload_project(L, prj);
		const char* result = project_get_name(prj);
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsBaseDir)
	{
		unload_project(L, prj);
		const char* result = project_get_base_dir(prj);
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsGuid)
	{
		unload_project(L, prj);
		const char* result = project_get_guid(prj);
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsLanguage)
	{
		unload_project(L, prj);
		const char* result = project_get_language(prj);
		CHECK_EQUAL("c++", result);
	}
}

