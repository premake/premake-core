/**
 * \file   host_args_tests.cpp
 * \brief  Automated tests for application command line argument processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "host/host.h"
#include "base/env.h"
#include "base/error.h"
#include "base/stream.h"
}

struct FxHostArgs
{
	Host host;
	Session sess;
	char buffer[8192];

	FxHostArgs()
	{
		host = host_create();
		sess = session_create();
		stream_set_buffer(Console, buffer);
	}

	~FxHostArgs()
	{
		session_destroy(sess);
		host_destroy(host);
		error_clear();
	}
};


SUITE(host)
{
	TEST_FIXTURE(FxHostArgs, ParseArgv_SetsAction_OnAction)
	{
		const char* argv[] = { "premake", "action", NULL };
		host_set_argv(host, argv);
		host_parse_argv(host);
		CHECK_EQUAL("action", env_get_action());
	}
}
