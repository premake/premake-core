/**
 * \file   fn_error_tests.cpp
 * \brief  Automated test for the error() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/error.h"
}

struct FnError
{
	Session sess;

	FnError()
	{
		sess = session_create();
	}

	~FnError()
	{
		session_destroy(sess);
		error_clear();
	}
};


SUITE(engine)
{
	TEST_FIXTURE(FnError, Error_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (error ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnError, Error_SetsSessionError_OnCall)
	{
		session_run_string(sess, 
			"error('an error message')");
		CHECK_EQUAL("[string \"error('an error message')\"]:1: an error message", error_get());
	}
}
