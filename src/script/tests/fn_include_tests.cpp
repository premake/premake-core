/**
 * \file   fn_include_tests.cpp
 * \brief  Automated test for the include() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"
extern "C" {
#include "base/cstr.h"
}


SUITE(script)
{
	TEST_FIXTURE(FxScript, Include_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (include ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Include_ReturnsValue_OnPremake4Found)
	{
		const char* result = script_run_string(script, 
			"return include('testing/test_files')");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Include_SetsError_OnFileNotFound)
	{
		script_run_string(script,
			"include('testing')");
		CHECK(cstr_ends_with(error_get(), "No such file or directory"));
	}
}
