/**
 * \file   fn_accessor_tests.cpp
 * \brief  Automated tests for the generic value getter/setter function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_tests.h"


SUITE(script)
{
	/**************************************************************************
	 * Initial state tests
	 **************************************************************************/

	TEST_FIXTURE(FxAccessor, Accessor_FunctionExists_OnStartup)
	{
		const char* result = script_run_string(script, 
			"return (location ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_RaisesError_OnNoActiveObject)
	{
		Script script = script_create();
		const char* result = script_run_string(script, "location()");
		CHECK_EQUAL("no active solution or project", result);
		script_destroy(script);
	}


	/**************************************************************************
	 * String field tests
	 **************************************************************************/

	TEST_FIXTURE(FxAccessor, Accessor_ReturnsNil_OnEmptyStringValue)
	{
		const char* result = script_run_string(script,
			"return (location() == nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_RaisesError_OnListValueAndStringField)
	{
		const char* result = script_run_string(script, 
			"location {}");
		CHECK_EQUAL("the field 'location' does not support lists of values", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_SetsField_OnStringField)
	{
		const char* result = script_run_string(script,
			"location 'MyLocation';"
			"return prj.location"   );
		CHECK_EQUAL("MyLocation", result);
	}

	TEST_FIXTURE(FxAccessor, Accessor_GetsField_OnStringField)
	{
		const char* result = script_run_string(script,
			"prj.location = 'MyLocation';"
			"return location()"   );
		CHECK_EQUAL("MyLocation", result);
	}

}
