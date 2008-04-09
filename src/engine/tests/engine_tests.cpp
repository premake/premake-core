/**
 * \file   engine_tests.cpp
 * \brief  Automated tests for the project scripting engine.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/base.h"
#include "project/project.h"
#include "engine/engine.h"
}


/**
 * \brief   Run the engine automated tests.
 * \returns OKAY if all tests completed successfully.
 * \note    Also runs the tests for all dependencies (everything but the host executable).
 */
int engine_tests()
{
	int status = base_tests();
	if (status == OKAY) status = project_tests();
	if (status == OKAY) status = tests_run_suite("session");
	if (status == OKAY) status = tests_run_suite("engine");
	if (status == OKAY) status = tests_run_suite("unload");
	return status;
}
