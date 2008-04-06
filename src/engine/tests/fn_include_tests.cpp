/**
 * \file   fn_include_tests.cpp
 * \brief  Automated test for the include() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/cstr.h"
#include "base/error.h"
}

struct FnInclude
{
	Session sess;

	FnInclude()
	{
		sess = session_create();
	}

	~FnInclude()
	{
		session_destroy(sess);
		error_clear();
	}
};


SUITE(engine)
{
	TEST_FIXTURE(FnInclude, Include_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (include ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnInclude, Include_ReturnsValue_OnPremake4Found)
	{
		const char* result = session_run_string(sess, 
			"return include('testing/test_files')");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnInclude, Include_SetsError_OnFileNotFound)
	{
		session_run_string(sess,
			"include('testing')");
		CHECK(cstr_ends_with(error_get(), "No such file or directory"));
	}
}
