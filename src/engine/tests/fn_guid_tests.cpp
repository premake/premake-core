/**
 * \file   fn_guid_tests.cpp
 * \brief  Automated tests for the guid() function.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/guid.h"
#include "base/error.h"
}

struct FnGuid
{
	Session sess;

	FnGuid()
	{
		sess = session_create();
	}

	~FnGuid()
	{
		session_destroy(sess);
		error_clear();
	}
};

struct FnGuid2 : FnGuid
{
	FnGuid2()
	{
		session_run_string(sess,
			"solution 'MySolution';"
			"prj = project 'MyProject';");
	}
};


SUITE(engine)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FnGuid, Guid_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (guid ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FnGuid, Guid_RaisesError_OnNoProject)
	{
		const char* result = session_run_string(sess, "guid '0C202E43-B9AF-4972-822B-5A42F0BF008C'");
		CHECK_EQUAL("[string \"guid '0C202E43-B9AF-4972-822B-5A42F0BF008C'\"]:1: no active project", result);
	}

	TEST_FIXTURE(FnGuid2, Guid_ReturnsDefaultValue_OnNoValueSet)
	{
		const char* result = session_run_string(sess, "return guid()");
		CHECK(result != NULL && guid_is_valid(result));
	}

	TEST_FIXTURE(FnGuid2, Guid_SetsField)
	{
		const char* result = session_run_string(sess, 
			"guid '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"return prj.guid");
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}

	TEST_FIXTURE(FnGuid2, Guid_ReturnsField_OnNoParams)
	{
		const char* result = session_run_string(sess, 
			"prj.guid = '0C202E43-B9AF-4972-822B-5A42F0BF008C';"
			"return guid()");
		CHECK_EQUAL("0C202E43-B9AF-4972-822B-5A42F0BF008C", result);
	}

	TEST_FIXTURE(FnGuid2, Guid_RaisesError_OnInvalidGuid)
	{
		const char* result = session_run_string(sess, "guid '0C2XXXX-B9AF-4972-822B-5A42F0BF008C'");
		CHECK_EQUAL("[string \"guid '0C2XXXX-B9AF-4972-822B-5A42F0BF008C'\"]:1: invalid GUID", result);
	}
}
