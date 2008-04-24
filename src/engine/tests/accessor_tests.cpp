/**
 * \file   accessor_tests.cpp
 * \brief  Automated tests for the generic value getter/setter function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "accessor_tests.h"


SUITE(engine)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FxAccessor, Accessor_FunctionExists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (location ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_RaisesError_OnNoActiveObject)
	{
		Session sess = session_create();
		const char* result = session_run_string(sess, "location()");
		CHECK_EQUAL("no active solution or project", result);
		session_destroy(sess);
	}


	/**************************************************************************
	 * String field tests
	 **************************************************************************/

	TEST_FIXTURE(FxAccessor, Accessor_ReturnsNil_OnEmptyStringValue)
	{
		const char* result = session_run_string(sess,
			"return (location() == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_RaisesError_OnListValueAndStringField)
	{
		const char* result = session_run_string(sess, 
			"location {}");
		CHECK_EQUAL("the field 'location' does not support lists of values", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_SetsField_OnStringField)
	{
		const char* result = session_run_string(sess,
			"location 'MyLocation';"
			"return prj.location"   );
		CHECK_EQUAL("MyLocation", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_GetsField_OnStringField)
	{
		const char* result = session_run_string(sess,
			"prj.location = 'MyLocation';"
			"return location()"   );
		CHECK_EQUAL("MyLocation", result);
	}

}
