/**
 * \file   fn_flags_tests.cpp
 * \brief  Automated tests for the flags() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Flags_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (flags ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Flags_Error_OnNoActiveObject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "flags {'Symbols'}");
		CHECK_EQUAL("no active configuration block", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Flags_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"flags {'Symbols'};"
			"return flags()[1]");
		CHECK_EQUAL("Symbols", result);
	}

	TEST_FIXTURE(FxAccessor, Flags_RaisesError_OnInvalidValue)
	{
		const char* result = script_run_string(script,
			"flags 'nosuch'");
		CHECK_EQUAL("invalid value 'nosuch'", result);
	}
}
