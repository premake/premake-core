/**
 * \file   env_tests.cpp
 * \brief  Automated tests from runtime environment state.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/env.h"
}


SUITE(base)
{
	TEST(EnvGetOs_IsNotUnknown)
	{
		enum OS os = env_get_os();
		CHECK(os != UnknownOS);
	}

	TEST(EnvGetOsName_DoesNotExplode)
	{
		const char* name = env_get_os_name();
		CHECK(name != NULL);
	}
}

