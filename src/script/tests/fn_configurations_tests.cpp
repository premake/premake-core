/**
 * \file   fn_configurations_tests.cpp
 * \brief  Automated tests for the configurations() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"

SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Configurations_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (configurations ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Configurations_Error_OnNoActiveSolution)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "configurations {'Debug'}");
		CHECK_EQUAL("no active solution", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Configurations_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"configurations {'Debug'};"
			"return configurations()[1]");
		CHECK_EQUAL("Debug", result);
	}
}
