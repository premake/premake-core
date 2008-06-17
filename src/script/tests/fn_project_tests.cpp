/**
 * \file   fn_project_tests.cpp
 * \brief  Automated tests for the project() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


struct FnProject : FxScript
{
	FnProject()
	{
		script_run_string(script,
			"sln = solution('MySolution');"
			"  configurations {'Debug','Release'};"
			"prj = project('MyProject')");
	}
};


SUITE(script)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FxScript, Project_Exists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (project ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxScript, Project_ReturnsNil_OnNoActiveProject)
	{
		const char* result = script_run_string(script,
			"return (project() == nil)");
		CHECK_EQUAL("true", result);
	}

	/**************************************************************************
	 * Object creation tests
	 **************************************************************************/

	TEST_FIXTURE(FxScript, Project_Fails_OnNoActiveSolution)
	{
		const char* result = script_run_string(script, "project('MyProject')");
		CHECK_EQUAL("no active solution", result);
	}

	TEST_FIXTURE(FnProject, Project_ReturnsNewObject_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (prj ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject, Project_ReturnsObject_OnActiveProject)
	{
		const char* result = script_run_string(script,
			"return (prj == project())");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject, Project_AddsToKeyList_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (prj == sln.projects['MyProject']);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject, Project_AddsToIndexList_OnNewName)
	{
		const char* result = script_run_string(script,
			"return (prj == sln.projects[1]);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject, Project_IncrementsTableSize_OnNewName)
	{
		const char* result = script_run_string(script,
			"return #sln.projects");
		CHECK_EQUAL("1", result);
	}

	TEST_FIXTURE(FnProject, Project_ReturnsSameObject_OnExistingName)
	{
		const char* result = script_run_string(script,
			"prj1 = project('SecondProject');"
			"return (prj == project('MyProject'))");
		CHECK_EQUAL("true", result);
	}
/*
	TEST_FIXTURE(FxScript, Project_RaisesError_OnNoConfigurations)
	{
		const char* result = script_run_string(script,
			"sln = solution('MySolution');"
			"prj = project('MyProject')");
		CHECK_EQUAL("no configurations defined", result);
	}
*/

	/**************************************************************************
	 * Initial object state tests
	 **************************************************************************/

	TEST_FIXTURE(FnProject, Project_SetsName)
	{
		const char* result = script_run_string(script, "return prj.name");
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FnProject, Project_SetsBaseDir)
	{
		const char* result = script_run_string(script, "return prj.basedir");
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FnProject, Project_SetsGuid)
	{
		const char* result = script_run_string(script, "return prj.guid");
		CHECK(result != NULL && strlen(result) == 36);
	}
}
