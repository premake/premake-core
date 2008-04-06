/**
 * \file   project_tests.cpp
 * \brief  Automated tests for the project objects API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/project.h"
}


/**
 * \brief   Run the project API automated tests.
 * \returns OKAY if all tests completed successfully.
 */
int project_tests()
{
	int status = tests_run_suite("fields");
	if (status == OKAY)  status = tests_run_suite("project");
	return status;
}
