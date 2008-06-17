/**
 * \file   host_results_tests.cpp
 * \brief  Automated test for application status reporting.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "host/host.h"
#include "base/error.h"
#include "base/stream.h"
}

struct FxResults
{
	Session sess;
	char buffer[1024];

	FxResults()
	{
		sess = session_create();
		stream_set_buffer(Console, buffer);
	}

	~FxResults()
	{
		session_destroy(sess);
		error_clear();
	}
};


SUITE(host)
{
	TEST_FIXTURE(FxResults, ReportResults_NoMessage_OnNoError)
	{
		host_report_results(sess);
		CHECK_EQUAL("", buffer);
	}

	TEST_FIXTURE(FxResults, ReportResults_ErrorMessage_OnError)
	{
		error_set("an error occurred");
		host_report_results(sess);
		CHECK_EQUAL("Error: an error occurred\n", buffer);
	}
}
