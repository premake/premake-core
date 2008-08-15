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
			"  configurations {'Debug','Release'};"
			"prj = project('MyProject');"
			"  prj.basedir = '/basedir';"
			"  guid '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"  language 'C++';"
			"  kind 'Console';"
			"  files { 'Hello.cpp', 'Goodbye.cpp' };"
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
		CHECK_EQUAL("/basedir", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_UnloadsFiles)
	{
		unload_project(L, prj);
		Strings files = project_get_files(prj);
		CHECK(strings_size(files) == 2);
		if (strings_size(files) == 2) {
			CHECK_EQUAL("Hello.cpp", strings_item(files, 0));
			CHECK_EQUAL("Goodbye.cpp", strings_item(files, 1));
		}
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_RepointsFiles_OnLocation)
	{
		script_run_string(script, "location 'build'; return prj");
		unload_project(L, prj);
		Strings files = project_get_files(prj);
		CHECK(strings_size(files) == 2);
		if (strings_size(files) == 2) {
			CHECK_EQUAL("../Hello.cpp", strings_item(files, 0));
			CHECK_EQUAL("../Goodbye.cpp", strings_item(files, 1));
		}
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsGuid)
	{
		unload_project(L, prj);
		const char* result = project_get_guid(prj);
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsKind)
	{
		unload_project(L, prj);
		const char* result = project_get_kind(prj);
		CHECK_EQUAL("Console", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsLanguage)
	{
		unload_project(L, prj);
		const char* result = project_get_language(prj);
		CHECK_EQUAL("C++", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsLocation_OnUnsetLocation)
	{
		unload_project(L, prj);
		const char* result = project_get_location(prj);
		CHECK_EQUAL("/basedir", result);
	}

	TEST_FIXTURE(FxUnloadProject, UnloadProject_SetsLocation_OnSetLocation)
	{
		script_run_string(script, "location 'location'; return prj");
		unload_project(L, prj);
		const char* result = project_get_location(prj);
		CHECK_EQUAL("/basedir/location", result);
	}
}

