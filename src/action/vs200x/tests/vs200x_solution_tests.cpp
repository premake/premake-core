/**
 * \file   vs200x_solution_tests.cpp
 * \brief  Automated tests for VS200x solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}

struct FxVs200xSln
{
	Session sess;
	Stream strm;
	Solution sln;
	char buffer[8192];

	FxVs200xSln()
	{
		sess = session_create();

		strm = stream_create_null();
		stream_set_buffer(strm, buffer);

		sln = solution_create();
	}

	~FxVs200xSln()
	{
		solution_destroy(sln);
		stream_destroy(strm);
		session_destroy(sess);
	}
};


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277Microsoft Visual Studio Solution File, Format Version 7.00\r\n",
			buffer);
	}

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277Microsoft Visual Studio Solution File, Format Version 8.00\r\n",
			buffer);
	}

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277\r\n"
			"Microsoft Visual Studio Solution File, Format Version 9.00\r\n"
			"# Visual Studio 2005\r\n",
			buffer);
	}
}
