/**
 * \file   fn_dofile_tests.cpp
 * \brief  Automated test for the dofile() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"
extern "C" {
#include "base/cstr.h"
#include "base/dir.h"
}


SUITE(script)
{
	TEST_FIXTURE(FxScript, DoFile_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (dofile ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, DoFile_ReturnsValue_OnValidFile)
	{
		const char* result = script_run_string(script, 
			"return dofile('testing/test_files/true.lua')");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, DoFile_SetsError_OnFileNotFound)
	{
		script_run_string(script,
			"dofile('nosuchfile.lua')");
		CHECK(cstr_ends_with(error_get(), "No such file or directory"));
	}

	TEST_FIXTURE(FxScript, DoFile_SetsCwd_BeforeScript)
	{
		const char* result = script_run_string(script, 
			"return dofile('testing/test_files/getcwd.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files"));
	}

	TEST_FIXTURE(FxScript, DoFile_SetsCwd_BeforeNestedScript)
	{
		const char* result = script_run_string(script, 
			"return dofile('testing/test_files/dofile.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files/nested"));
	}

	TEST_FIXTURE(FxScript, DoFile_RestoresCwd_AfterNestedScript)
	{
		const char* result = script_run_string(script, 
			"return dofile('testing/test_files/dofile_getcwd.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files"));
	}

	TEST_FIXTURE(FxScript, DoFile_RestoresCwd_OnFileNotFound)
	{
		script_run_string(script,
			"dofile('testing/test_files/nosuchfile.lua')");
		const char* cwd = dir_get_current();
		CHECK(cstr_ends_with(cwd, "/src"));
	}

	TEST_FIXTURE(FxScript, DoFile_SetsFileGlobal)
	{
		const char* result = script_run_string(script,
			"return dofile('testing/test_files/_FILE.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files/_FILE.lua"));
	}
}
