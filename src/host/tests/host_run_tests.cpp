/**
 * \file   host_run_tests.cpp
 * \brief  Automated test for the host script execution logic.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "host/host.h"
#include "base/dir.h"
#include "base/error.h"
}

struct FxHostRun
{
	Host host;

	FxHostRun()
	{
		host = host_create();
		dir_set_current("testing/test_files");
	}

	~FxHostRun()
	{
		dir_set_current("../..");
		host_destroy(host);
		error_clear();
	}
};

SUITE(host)
{
	/**********************************************************************
	 * host_run_action() tests
	 **********************************************************************/

	TEST_FIXTURE(FxHostRun, HostRunAction_ReturnsNotOkay_OnInvalidAction)
	{
		const char* argv[] = { "premake", "nonesuch", NULL };
		host_set_argv(host, argv);
		int result = host_run_action(host);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxHostRun, HostRunAction_SetsError_OnInvalidAction)
	{
		const char* argv[] = { "premake", "nonesuch", NULL };
		host_set_argv(host, argv);
		host_run_action(host);
		CHECK_EQUAL("invalid action 'nonesuch'", error_get());
	}
}
