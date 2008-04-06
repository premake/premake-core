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
}
