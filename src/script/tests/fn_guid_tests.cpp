/**
 * \file   fn_guid_tests.cpp
 * \brief  Automated tests for the guid() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"
extern "C" {
#include "base/guid.h"
}


SUITE(script)
{
	TEST_FIXTURE(FxAccessor, Guid_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (guid ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Guid_Error_OnNoActiveProject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "guid()");
		CHECK_EQUAL("no active project", result);
		script_destroy(script);
	}

	TEST_FIXTURE(FxAccessor, Guid_CanRoundtrip)
	{
		const char* result = script_run_string(script,
			"guid '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"return guid()");
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}

	TEST_FIXTURE(FxAccessor, Guid_RaisesError_OnInvalidGuid)
	{
		const char* result = script_run_string(script,
			"guid '0C202E43-XXXX-4972-822B-5A42F0BF008C'");
		CHECK_EQUAL("invalid value '0C202E43-XXXX-4972-822B-5A42F0BF008C'", result);
	}
}
