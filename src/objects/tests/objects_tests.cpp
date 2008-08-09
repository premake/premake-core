/**
 * \file   objects_tests.cpp
 * \brief  Automated tests for the project-related objects.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "objects/objects.h"
}


/**
 * \brief   Run the objects library automated tests.
 * \returns OKAY if all tests completed successfully.
 */
int objects_tests()
{
	int z = OKAY;
	if (z == OKAY)  z = tests_run_suite("fields");
	if (z == OKAY)  z = tests_run_suite("project");
	if (z == OKAY)  z = tests_run_suite("project_config");
	if (z == OKAY)  z = tests_run_suite("session");
	return z;
}
