/**
 * \file   fn_getcwd_tests.cpp
 * \brief  Automated test for the getcwd() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"
extern "C" {
#include "base/cstr.h"
}


SUITE(script)
{
	TEST_FIXTURE(FxScript, GetCwd_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (os.getcwd ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, GetCwd_ReturnsCwd)
	{
		const char* result = script_run_string(script, 
			"return os.getcwd()");
		CHECK(cstr_ends_with(result, "/src"));
	}
}
