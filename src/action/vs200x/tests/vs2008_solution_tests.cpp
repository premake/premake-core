/**
 * \file   vs2008_solution_tests.cpp
 * \brief  Automated tests for VS2008 solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs2008_Signature_IsCorrect)
	{
		vs2008_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277\r\n"
			"Microsoft Visual Studio Solution File, Format Version 10.00\r\n"
			"# Visual Studio 2008\r\n",
			buffer);
	}

}
