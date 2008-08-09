/**
 * \file   host_help_tests.cpp
 * \brief  Automated test for application help and version display.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "host/host.h"
#include "base/error.h"
#include "base/stream.h"
}

struct FxHostHelp
{
	Host host;
	Session sess;
	char buffer[8192];

	FxHostHelp()
	{
		host = host_create();
		sess = session_create();
		stream_set_buffer(Console, buffer);
	}

	~FxHostHelp()
	{
		session_destroy(sess);
		host_destroy(host);
		error_clear();
	}
};


SUITE(host)
{
	/**********************************************************************
	 * Do nothing if an action is set.
	 **********************************************************************/

	TEST_FIXTURE(FxHostHelp, Help_ReturnsOkay_OnAction)
	{
		const char* argv[] = { "premake", "vs2005", NULL };
		host_set_argv(host, argv);
		int result = host_show_help(host);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxHostHelp, Help_PrintsNothing_OnAction)
	{
		const char* argv[] = { "premake", "vs2005", NULL };
		host_set_argv(host, argv);
		host_show_help(host);
		CHECK_EQUAL("", buffer);
	}


	/**********************************************************************
	 * Should display short help (and end loop) if there is no action set.
	 **********************************************************************/

	TEST_FIXTURE(FxHostHelp, Help_ReturnsNotOkay_OnNoAction)
	{
		const char* argv[] = { "premake", NULL };
		host_set_argv(host, argv);
		int result = host_show_help(host);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxHostHelp, Help_ShowsShortHelp_OnNoAction)
	{
		const char* argv[] = { "premake", NULL };
		host_set_argv(host, argv);
		host_show_help(host);
		CHECK_EQUAL(HOST_SHORT_HELP "\n", buffer);
	}
}
