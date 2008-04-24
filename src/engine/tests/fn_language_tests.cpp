/**
 * \file   fn_language_tests.cpp
 * \brief  Automated tests for the language() function.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "accessor_tests.h"


SUITE(engine)
{
	TEST_FIXTURE(FxAccessor, Language_Exists_OnStartup)
	{
		const char* result = session_run_string(sess, 
			"return (language ~= nil)");
		CHECK_EQUAL("true", result);
	}

	TEST_FIXTURE(FxAccessor, Language_CanRoundtrip)
	{
		const char* result = session_run_string(sess,
			"language 'c++';"
			"return language()");
		CHECK_EQUAL("c++", result);
	}

	TEST_FIXTURE(FxAccessor, Language_RaisesError_OnInvalidLanguage)
	{
		const char* result = session_run_string(sess,
			"language 'nosuch'");
		CHECK_EQUAL("invalid value 'nosuch'", result);
	}
}
