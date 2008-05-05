/**
 * \file   script_tests.h
 * \brief  Common fixtures for script function tests.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "testing/testing.h"
extern "C" {
#include "script/script.h"
#include "base/error.h"
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


struct FxAccessor : FxScript
{
	FxAccessor()
	{
		script_run_string(script,
			"sln = solution 'MySolution';"
			"prj = project 'MyProject';");
	}
};
