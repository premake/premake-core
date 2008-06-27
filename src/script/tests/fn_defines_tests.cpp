/**
 * \file   fn_defines_tests.cpp
 * \brief  Automated tests for the defines() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Defines_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (defines ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Defines_Error_OnNoActiveObject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "defines {'DEBUG'}");
		CHECK_EQUAL("no active configuration block", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Defines_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"defines {'DEBUG'};"
			"return defines()[1]");
		CHECK_EQUAL("DEBUG", result);
	}
}
