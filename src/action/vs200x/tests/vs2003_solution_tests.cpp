/**
 * \file   vs2003_solution_tests.cpp
 * \brief  Automated tests for VS2003 solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}

#include "vs200x_tests.h"


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2003_Signature_IsCorrect)
	{
		session_set_action(sess, "vs2003");
		vs2003_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"Microsoft Visual Studio Solution File, Format Version 8.00\r\n",
			buffer);
	}


	/**********************************************************************
	 * Solution configuration tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200x, Vs2003_SolutionConfiguration_IsCorrect)
	{
		vs2003_solution_configuration(sess, sln, strm);
		CHECK_EQUAL(
			"Global\n"
			"\tGlobalSection(SolutionConfiguration) = preSolution\n"
			"\t\tDebug = Debug\n"
			"\t\tRelease = Release\n"
			"\tEndGlobalSection\n",
			buffer);
	}

}
