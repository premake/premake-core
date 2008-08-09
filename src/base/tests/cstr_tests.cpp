/**
 * \file   cstr_tests.cpp
 * \brief  C string automated tests.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/cstr.h"
}

SUITE(cstr)
{
	/**************************************************************************
	 * cstr_contains() tests
	 **************************************************************************/

	TEST(CStrContains_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_contains("Abcdef", "cd"));
	}

	TEST(CStrContains_ReturnsFalse_OnMismatch)
	{
		CHECK(!cstr_contains("Abcdef", "xy"));
	}


	/**************************************************************************
	 * cstr_ends_with() tests
	 **************************************************************************/

	TEST(CStrEndsWith_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_ends_with("Abcdef", "def"));
	}

	TEST(CStrEndsWith_ReturnsFalse_OnMismatch)
	{
		CHECK(!cstr_ends_with("Abcdef", "ghi"));
	}

	TEST(CStrEndsWith_ReturnsFalse_OnLongerNeedle)
	{
		CHECK(!cstr_ends_with("Abc", "Abcdef"));
	}

	TEST(CStrEndsWith_ReturnsFalse_OnNullHaystack)
	{
		CHECK(!cstr_ends_with(NULL, "ghi"));
	}

	TEST(CStrEndsWith_ReturnsFalse_OnNullNeedle)
	{
		CHECK(!cstr_ends_with("Abc", NULL));
	}


	/**************************************************************************
	 * cstr_eq() tests
	 **************************************************************************/

	TEST(CStrEq_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_eq("A string", "A string"));
	}

	TEST(CStrEq_ReturnsFalse_OnMismatch)
	{
		CHECK(!cstr_eq("A string", "A different string"));
	}

	TEST(CStrEq_ReturnsFalse_OnNullTarget)
	{
		CHECK(!cstr_eq(NULL, "something"));
	}

	TEST(CStrEq_ReturnsFalse_OnNullPattern)
	{
		CHECK(!cstr_eq("something", NULL));
	}


	/**************************************************************************
	 * cstr_eqi() tests
	 **************************************************************************/

	TEST(CStrEqi_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_eqi("A string", "a String"));
	}

	TEST(CStrEqi_ReturnsFalse_OnMismatch)
	{
		CHECK(!cstr_eqi("A string", "a different string"));
	}

	TEST(CStrEqi_ReturnsFalse_OnNullTarget)
	{
		CHECK(!cstr_eqi(NULL, "something"));
	}

	TEST(CStrEqi_ReturnsFalse_OnNullPattern)
	{
		CHECK(!cstr_eqi("something", NULL));
	}


	/**************************************************************************
	 * cstr_format() tests
	 **************************************************************************/

	TEST(CstrFormat_ReturnsFormatted)
	{
		char* result = cstr_format("$(OBJDIR)/%s.o", "hello");
		CHECK_EQUAL("$(OBJDIR)/hello.o", result);
	}


	/**************************************************************************
	 * cstr_matches_pattern() tests
	 **************************************************************************/

	TEST(CStrMatchesPattern_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_matches_pattern("01234", "%d*"));
	}

	TEST(CStrMatchesPattern_ReturnsFalse_OnNonMatch)
	{
		CHECK(!cstr_matches_pattern("01234", "%a*"));
	}

	TEST(CStrMatchesPattern_ReturnsTrue_OnCaseMismatch)
	{
		CHECK(cstr_matches_pattern("Debug", "debug"));
	}


	/**************************************************************************
	 * cstr_starts_with() tests
	 **************************************************************************/

	TEST(CStrStartsWith_ReturnsTrue_OnMatch)
	{
		CHECK(cstr_starts_with("Abcdef", "Abc"));
	}

	TEST(CStrStartsWith_ReturnsFalse_OnMismatch)
	{
		CHECK(!cstr_starts_with("Abcdef", "ghi"));
	}

	TEST(CStrStartsWith_ReturnsFalse_OnLongerNeedle)
	{
		CHECK(!cstr_starts_with("Abc", "Abcdef"));
	}

	TEST(CStrStartsWith_ReturnsFalse_OnNullHaystack)
	{
		CHECK(!cstr_starts_with(NULL, "ghi"));
	}

	TEST(CStrStartsWith_ReturnsFalse_OnNullNeedle)
	{
		CHECK(!cstr_starts_with("Abc", NULL));
	}


	/**********************************************************************
	 * cstr_trim() tests
	 **********************************************************************/

	TEST(CStrTrim_DoesNothing_OnNoMatch)
	{
		char buffer[32];
		strcpy(buffer, "Msg");
		cstr_trim(buffer, '/');
		CHECK_EQUAL("Msg", buffer);
	}

	TEST(CStrTrim_DoesTrim_OnMatch)
	{
		char buffer[32];
		strcpy(buffer, "Msg///");
		cstr_trim(buffer, '/');
		CHECK_EQUAL("Msg", buffer);
	}
}
