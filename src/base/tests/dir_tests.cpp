/**
 * \file   dir_tests.cpp
 * \brief  Directory handling automated tests.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/dir.h"
#include "base/cstr.h"
}

SUITE(base)
{
	TEST(DirExists_ReturnsOkay_OnEmptyPath)
	{
		int result = dir_exists("");
		CHECK(result);
	}

	TEST(DirGetCurrent_ReturnsCurrent_WithSlashes)
	{
		const char* result = dir_get_current();
		CHECK(cstr_ends_with(result, "/src"));
	}
}
