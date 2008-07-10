/**
 * \file   filter_tests.cpp
 * \brief  Automated tests for the configuration filters API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
#include "project/filter.h"
}


struct FxFilter
{
	Filter flt;
	Strings terms;

	FxFilter()
	{
		flt = filter_create();
		terms = strings_create();
		strings_add(terms, "Debug");
	}

	~FxFilter()
	{
		filter_destroy(flt);
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
		CHECK(filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsFalse_OnNullKey)
	{
		CHECK(!filter_is_match(flt, terms));
	}

	TEST_FIXTURE(FxFilter, IsMatch_ReturnsFalse_OnValueMismatch)
	{
		filter_set_value(flt, FilterConfig, "Release");
		CHECK(!filter_is_match(flt, terms));
	}
}


