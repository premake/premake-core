/**
 * \file   testing.cpp
 * \brief  Automated testing framework.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <cstdio>
#include "testing.h"
#include "UnitTest++/src/TestReporterStdout.h"


/**
 *  Run a particular suite of tests.
 * \param   suite    The name of the suite to run.
 * \returns OKAY if all tests passed successfully.
 */
int tests_run_suite(const char* suite)
{
	UnitTest::TestReporterStdout reporter;
	std::printf("Testing %s...\n", suite);
	return UnitTest::RunAllTests(reporter, UnitTest::Test::GetTestList(), suite);
}
