/**
 * \file   fn_configuration_tests.cpp
 * \brief  Automated tests for the configuration() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"

struct FnConfiguration : FxScript
{
	FnConfiguration()
	{
		script_run_string(script,
			"sln = solution('MySolution');"
			"  configurations {'Debug','Release'};"
			"prj = project('MyProject');"
			"cfg = configuration('Debug')");
	}
};


SUITE(script)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FxScript, Configuration_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (configuration ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Configuration_ReturnsNil_OnNoActiveProject)
	{
		const char* result = script_run_string(script,
			"return (configuration() == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Configuration_RaisesError_OnNoActiveContainer)
	{
		const char* result = script_run_string(script, "configuration('Debug')");
		CHECK_EQUAL("no active solution or project", result);
	}


	/**************************************************************************
	 * Object creation tests
	 **************************************************************************/

	TEST_FIXTURE(FnConfiguration, Configuration_ReturnsObject_OnConfigName)
	{
		const char* result = script_run_string(script, "return (cfg ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_ReturnsPreviousObject_OnNoParameters)
	{
		const char* result = script_run_string(script, "return (cfg == configuration())");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_AddsToContainer)
	{
		const char* result = script_run_string(script, "return (#prj.blocks == 2)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_DoesNothing_OnSimpleField)
	{
		const char* result = script_run_string(script, "return (cfg.objdir == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_SetsEmptyList_OnListField)
	{
		const char* result = script_run_string(script, "return (#cfg.defines == 0)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_SetsTerms_OnSingleValue)
	{
		const char* result = script_run_string(script, 
			"cfg = configuration 'Debug';"
			"return (#cfg.terms == 1 and cfg.terms[1] == 'Debug')");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnConfiguration, Configuration_SetsTerms_OnMultipleValues)
	{
		const char* result = script_run_string(script, 
			"cfg = configuration { 'Debug', 'windows' };"
			"return (#cfg.terms == 2 and cfg.terms[1] == 'Debug' and cfg.terms[2] == 'windows')");
		CHECK_EQUAL("true", result);
	}
}
