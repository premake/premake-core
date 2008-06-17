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

/* Mock steps for testing host_run_steps */

static int num_step_calls;

static int MockStepOkay(Session sess)
{
	sess = 0;
	num_step_calls++;
	return OKAY;
}

static int MockStepFail(Session sess)
{
	sess = 0;
	return !OKAY;
}


struct FxHostRun
{
	Session sess;

	FxHostRun()
	{
		num_step_calls = 0;
		sess = session_create();
		dir_set_current("testing/test_files");
	}

	~FxHostRun()
	{
		dir_set_current("../..");
		session_destroy(sess);
		error_clear();
	}
};

SUITE(host)
{
	/**********************************************************************
	 * host_run_script() tests
	 **********************************************************************/

	TEST_FIXTURE(FxHostRun, HostRunScript_ReturnsOkay_OnSuccess)
	{
		int result = host_run_script(sess);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxHostRun, HostRunScript_RunsDefaultFile_OnNoFileArg)
	{
		host_run_script(sess);
		const char* result = session_run_string(sess,
			"return script_has_run");
		CHECK_EQUAL("true", result);
	}


	/**********************************************************************
	 * host_run_steps() tests
	 **********************************************************************/

	TEST_FIXTURE(FxHostRun, HostRunSteps_ReturnsOkay_OnAllStepsSucceed)
	{
		HostExecutionStep steps[] = { MockStepOkay, NULL };
		int result = host_run_steps(sess, steps);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxHostRun, HostRunSteps_RunsAllSteps)
	{
		HostExecutionStep steps[] = { MockStepOkay, MockStepOkay, MockStepOkay, NULL };
		host_run_steps(sess, steps);
		CHECK(num_step_calls == 3);
	}

	TEST_FIXTURE(FxHostRun, HostRunSteps_ReturnsNotOkay_OnError)
	{
		HostExecutionStep steps[] = { MockStepFail, NULL };
		int result = host_run_steps(sess, steps);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxHostRun, HostRunSteps_StopsRunning_OnError)
	{
		HostExecutionStep steps[] = { MockStepOkay, MockStepFail, MockStepOkay, NULL };
		host_run_steps(sess, steps);
		CHECK(num_step_calls == 1);
	}


	/**********************************************************************
	 * host_run_action() tests
	 **********************************************************************/

	TEST_FIXTURE(FxHostRun, HostRunAction_ReturnsNotOkay_OnInvalidAction)
	{
		const char* argv[] = { "premake", "nonesuch", NULL };
		host_set_argv(argv);
		int result = host_run_action(sess);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxHostRun, HostRunAction_SetsError_OnInvalidAction)
	{
		const char* argv[] = { "premake", "nonesuch", NULL };
		host_set_argv(argv);
		host_run_action(sess);
		CHECK_EQUAL("invalid action 'nonesuch'", error_get());
	}
}
