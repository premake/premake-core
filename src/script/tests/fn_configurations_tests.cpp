/**
 * \file   fn_configurations_tests.cpp
 * \brief  Automated tests for the configurations() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"

SUITE(script)
{
	TEST_FIXTURE(FxScript, Configurations_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (configurations ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Configurations_Error_OnNoActiveSolution)
	{
		const char* result = script_run_string(script, "configurations {'Debug'}");
		CHECK_EQUAL("no active solution", result);
	}

	TEST_FIXTURE(FxScript, Configurations_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"solution 'MySolution';"
			" configurations {'Debug','Release'};"
			"return configurations()[1]");
		CHECK_EQUAL("Debug", result);
	}

	TEST_FIXTURE(FxScript, Configurations_RaisesError_OnProjectDefined)
	{
		const char* result = script_run_string(script,
			"solution 'MySolution';"
			" configurations {'Debug','Release'};"
			"project 'MyProject';"
			" configurations {'DebugDLL','ReleaseDLL'}");
		CHECK_EQUAL("configurations may not be modified after projects are defined", result);
	}

}
