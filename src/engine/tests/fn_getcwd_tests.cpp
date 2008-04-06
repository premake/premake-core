/**
 * \file   fn_getcwd_tests.cpp
 * \brief  Automated test for the getcwd() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/cstr.h"
}


struct FnGetCwd
{
	Session sess;

	FnGetCwd()
	{
		sess = session_create();
	}

	~FnGetCwd()
	{
		session_destroy(sess);
	}
};


SUITE(engine)
{
	TEST_FIXTURE(FnGetCwd, GetCwd_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (os.getcwd ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnGetCwd, GetCwd_ReturnsCwd)
	{
		const char* result = session_run_string(sess, 
			"return os.getcwd()");
		CHECK(cstr_ends_with(result, "/src"));
	}
}
