/**
 * \file   fn_language_tests.cpp
 * \brief  Automated tests for the language() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Language_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (language ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Guid_Error_OnNoActiveObject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "language()");
		CHECK_EQUAL("no active solution or project", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Language_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"language 'c++';"
			"return language()");
		CHECK_EQUAL("c++", result);
	}

	TEST_FIXTURE(FxAccessor, Language_RaisesError_OnInvalidLanguage)
	{
		const char* result = script_run_string(script,
			"language 'nosuch'");
		CHECK_EQUAL("invalid value 'nosuch'", result);
	}
}
