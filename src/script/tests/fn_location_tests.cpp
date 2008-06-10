/**
 * \file   fn_location_tests.cpp
 * \brief  Automated tests for the location() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Location_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (location ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Location_Error_OnNoActiveProject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "location()");
		CHECK_EQUAL("no active solution or project", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Location_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"location 'elsewhere';"
			"return location()");
		CHECK_EQUAL("elsewhere", result);
	}
}
