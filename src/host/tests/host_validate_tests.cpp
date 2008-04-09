/**
 * \file   host_validate_tests.cpp
 * \brief  Automated tests for session validation.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "host/host.h"
#include "base/error.h"
}

struct FxHostValidate
{
	Session sess;
	Solution sln;
	char buffer[8192];

	FxHostValidate()
	{
		sess = session_create();
		stream_set_buffer(Console, buffer);
	}

	~FxHostValidate()
	{
		session_destroy(sess);
		error_clear();
		host_set_argv(NULL);
	}

	void AddSolution()
	{
		sln = solution_create();
		session_add_solution(sess, sln);
	}
};


SUITE(host)
{
	TEST_FIXTURE(FxHostValidate, Validate_ReturnsOkay_OnValidSession)
	{
		AddSolution();
		int result = host_validate_session(sess);
		CHECK(result == OKAY);
	}


	TEST_FIXTURE(FxHostValidate, Validate_ReturnsNotOkay_OnNoSolutions)
	{
		int result = host_validate_session(sess);
		CHECK(result != OKAY);
	}


	TEST_FIXTURE(FxHostValidate, Validate_SetsError_OnNoSolutions)
	{
		host_validate_session(sess);
		CHECK_EQUAL("no solutions defined", error_get());
	}
}
