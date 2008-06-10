/**
 * \file   fn_files_tests.cpp
 * \brief  Automated tests for the files() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Files_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (files ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Files_Error_OnNoActiveProject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "files {'hello.c'}");
		CHECK_EQUAL("no active project", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Files_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"files {'hello.c'};"
			"return files()[1]");
		CHECK_EQUAL("hello.c", result);
	}
}
