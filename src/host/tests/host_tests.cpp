/**
 * \file   host_tests.cpp
 * \brief  Main executable automated tests.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "engine/engine.h"
#include "host/host.h"
}

	
/**
 * Run the automated host tests.
 * \returns OKAY if all tests completed successfully.
 * \note    Also runs the tests for all dependencies, which for the host is everything.
 */
int host_tests()
{
	int status = engine_tests();
	if (status == OKAY) status = tests_run_suite("action");
	if (status == OKAY) status = tests_run_suite("host");
	return status;
}
