/**
 * \file   fn_project_tests.cpp
 * \brief  Automated tests for the project() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/error.h"
}

struct FnProject
{
	Session sess;

	FnProject()
	{
		sess = session_create();
	}

	~FnProject()
	{
		session_destroy(sess);
		error_clear();
	}
};

struct FnProject2
{
	Session sess;

	FnProject2()
	{
		sess = session_create();
		session_run_string(sess,
			"sln = solution('MySolution');"
			"prj = project('MyProject')");
	}

	~FnProject2()
	{
		session_destroy(sess);
		error_clear();
	}
};


SUITE(engine)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FnProject, Project_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (project ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject, Project_ReturnsNil_OnNoActiveProject)
	{
		const char* result = session_run_string(sess,
			"return (project() == nil)");
		CHECK_EQUAL("true", result);
	}

	/**************************************************************************
	 * Object creation tests
	 **************************************************************************/

	TEST_FIXTURE(FnProject, Project_Fails_OnNoActiveSolution)
	{
		const char* result = session_run_string(sess, "project('MyProject')");
		CHECK_EQUAL("no active solution", result);
	}

	TEST_FIXTURE(FnProject2, Project_ReturnsNewObject_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (prj ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject2, Project_ReturnsObject_OnActiveProject)
	{
		const char* result = session_run_string(sess,
			"return (prj == project())");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject2, Project_AddsToKeyList_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (prj == sln.projects['MyProject']);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject2, Project_AddsToIndexList_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return (prj == sln.projects[1]);");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnProject2, Project_IncrementsTableSize_OnNewName)
	{
		const char* result = session_run_string(sess,
			"return #sln.projects");
		CHECK_EQUAL("1", result);
	}

	TEST_FIXTURE(FnProject2, Project_ReturnsSameObject_OnExistingName)
	{
		const char* result = session_run_string(sess,
			"prj1 = project('SecondProject');"
			"return (prj == project('MyProject'))");
		CHECK_EQUAL("true", result);
	}


	/**************************************************************************
	 * Initial object state tests
	 **************************************************************************/

	TEST_FIXTURE(FnProject2, Project_SetsName)
	{
		const char* result = session_run_string(sess, "return prj.name");
		CHECK_EQUAL("MyProject", result);
	}

	TEST_FIXTURE(FnProject2, Project_SetsBaseDir)
	{
		const char* result = session_run_string(sess, "return prj.basedir");
		CHECK_EQUAL("(string)", result);
	}

	TEST_FIXTURE(FnProject2, Project_SetsGuid)
	{
		const char* result = session_run_string(sess, "return prj.guid");
		CHECK(result != NULL && strlen(result) == 36);
	}
}
