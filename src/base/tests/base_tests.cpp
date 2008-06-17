/**
 * \file   base_tests.cpp
 * \brief  Automated tests for Premake base library.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/base.h"
}


/**
 * \brief   Run the base library automated tests.
 * \returns OKAY if all tests completed successfully.
 */
int base_tests()
{
	int status = tests_run_suite("cstr");
	if (status == OKAY) status = tests_run_suite("base");
	return status;
}
