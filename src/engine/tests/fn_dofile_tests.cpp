/**
 * \file   fn_dofile_tests.cpp
 * \brief  Automated test for the dofile() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/cstr.h"
#include "base/dir.h"
#include "base/error.h"
}

struct FnDoFile
{
	Session sess;

	FnDoFile()
	{
		sess = session_create();
	}

	~FnDoFile()
	{
		session_destroy(sess);
		error_clear();
	}
};


SUITE(engine)
{
	TEST_FIXTURE(FnDoFile, DoFile_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (dofile ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnDoFile, DoFile_ReturnsValue_OnValidFile)
	{
		const char* result = session_run_string(sess, 
			"return dofile('testing/test_files/true.lua')");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnDoFile, DoFile_SetsError_OnFileNotFound)
	{
		session_run_string(sess,
			"dofile('nosuchfile.lua')");
		CHECK(cstr_ends_with(error_get(), "No such file or directory"));
	}

	TEST_FIXTURE(FnDoFile, DoFile_SetsCwd_BeforeScript)
	{
		const char* result = session_run_string(sess, 
			"return dofile('testing/test_files/getcwd.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files"));
	}

	TEST_FIXTURE(FnDoFile, DoFile_SetsCwd_BeforeNestedScript)
	{
		const char* result = session_run_string(sess, 
			"return dofile('testing/test_files/dofile.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files/nested"));
	}

	TEST_FIXTURE(FnDoFile, DoFile_RestoresCwd_AfterNestedScript)
	{
		const char* result = session_run_string(sess, 
			"return dofile('testing/test_files/dofile_getcwd.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files"));
	}

	TEST_FIXTURE(FnDoFile, DoFile_RestoresCwd_OnFileNotFound)
	{
		session_run_string(sess,
			"dofile('testing/test_files/nosuchfile.lua')");
		const char* cwd = dir_get_current();
		CHECK(cstr_ends_with(cwd, "/src"));
	}

	TEST_FIXTURE(FnDoFile, DoFile_SetsFileGlobal)
	{
		const char* result = session_run_string(sess,
			"return dofile('testing/test_files/_FILE.lua')");
		CHECK(cstr_ends_with(result, "testing/test_files/_FILE.lua"));
	}
}
