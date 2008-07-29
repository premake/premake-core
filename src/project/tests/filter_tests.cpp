/**
 * \file   filter_tests.cpp
 * \brief  Automated tests for the configuration filters API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "session/session.h"
}


struct FxFilter
{
	Session sess;
	Filter flt;
	Strings terms;

	FxFilter()
	{
		sess = session_create();
		flt = session_get_filter(sess);
		terms = strings_create();
	}

	~FxFilter()
	{
		session_destroy(sess);
		strings_destroy(terms);
	}
};


SUITE(project)
{
	TEST_FIXTURE(FxFilter, Create_ReturnsObject_OnSuccess)
	{
		CHECK(flt != NULL);
	}

	TEST_FIXTURE(FxFilter, SetValue_CanRoundtrip)
	{
		filter_set_value(flt, FilterConfig, "Debug");
		const char* result = filter_get_value(flt, FilterConfig);
		CHECK_EQUAL("Debug", result);
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsTrue_OnValueMatch)
	{
		filter_set_value(flt, FilterConfig, "Debug");
		strings_add(terms, "Debug");
		CHECK(filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsFalse_OnNullKey)
	{
		strings_add(terms, "Debug");
		CHECK(!filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsFalse_OnValueMismatch)
	{
		filter_set_value(flt, FilterConfig, "Release");
		strings_add(terms, "Debug");
		CHECK(!filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsTrue_OnWildcardMatch)
	{
		filter_set_value(flt, FilterConfig, "DebugDLL");
		strings_add(terms, "Debug.*");
		CHECK(filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsTrue_OnSetMatch)
	{
		filter_set_value(flt, FilterAction, "vs2008");
		strings_add(terms, "vs200[58]");
		CHECK(filter_is_match(flt, terms));
	}
}


