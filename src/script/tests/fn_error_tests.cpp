/**
 * \file   fn_error_tests.cpp
 * \brief  Automated test for the error() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"

SUITE(script)
{
	TEST_FIXTURE(FxScript, Error_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (error ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Error_SetsSessionError_OnCall)
	{
		script_run_string(script, 
			"error('an error message')");
		CHECK_EQUAL("[string \"error('an error message')\"]:1: an error message", error_get());
	}
}
