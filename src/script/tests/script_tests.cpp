/**
 * \file   script_tests.cpp
 * \brief  Automated test for the project scripting engine.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "script/script.h"
#include "base/error.h"
}


/**
 * Run the suite of project scripting engine automated tests.
 * \returns OKAY if all tests completed successfully.
 */
int script_tests()
{
	int z = OKAY;
	if (z == OKAY)  z = tests_run_suite("script");
	if (z == OKAY)  z = tests_run_suite("unload");
	return z;
}


struct FxScript
{
	Script script;

	FxScript()
	{
		script = script_create();
	}

	~FxScript()
	{
		script_destroy(script);
		error_clear();
	}
};


SUITE(script)
{
	TEST_FIXTURE(FxScript, ScriptCreate_ReturnsObject)
	{
		CHECK(script != NULL);
	}
}

