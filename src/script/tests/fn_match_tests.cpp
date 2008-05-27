/**
 * \file   fn_match_tests.cpp
 * \brief  Automated test for the match() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"
extern "C" {
}

struct FxMatch : FxScript
{
	FxMatch()
	{
		script_run_string(script,
			"function contains(tbl,val)"
			"  for i,v in ipairs(files) do"
			"    if (v == val) then return true end"
			"  end"
			"  return false;"
			"end");
	};
};


SUITE(script)
{
	TEST_FIXTURE(FxMatch, Match_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (match ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxMatch, Match_ReturnsEmptyTable_OnNoMatches)
	{
		const char* result = script_run_string(script,
			"return #match('*.xyz')");
		CHECK_EQUAL("0", result);
	}

	TEST_FIXTURE(FxMatch, Match_ReturnsMatches_OnMatch)
	{
		const char* result = script_run_string(script,
			"files = match('testing/test_files/*.lua');"
			"return contains(files, 'testing/test_files/true.lua');");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxMatch, Match_Recurses_OnDoubleStar)
	{
		const char* result = script_run_string(script,
			"files = match('testing/test_files/**.lua');"
			"return contains(files, 'testing/test_files/nested/getcwd.lua');");
		CHECK_EQUAL("true", result);
	}
}
