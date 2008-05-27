/**
 * \file   string_tests.cpp
 * \brief  Dynamic string automated tests.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/string.h"
}

SUITE(base)
{
	/**************************************************************************
	 * string_create() tests
	 **************************************************************************/

	TEST(StringCreate_ReturnsNull_OnNull)
	{
		String str = string_create(NULL);
		CHECK(str == NULL);
	}


	/**************************************************************************
	 * string_destroy() tests
	 **************************************************************************/

	TEST(StringDestroy_DoesNoOp_OnNull)
	{
		string_destroy(NULL);
		CHECK(1);
	}


	/**************************************************************************
	 * string_cstr() tests
	 **************************************************************************/

	TEST(StringCStr_ReturnsNull_OnNullString)
	{
		CHECK(string_cstr(NULL) == NULL);
	}
}

