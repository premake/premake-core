/**
 * \file   vs200x_xml_tests.cpp
 * \brief  Automated tests for Visual Studio XML output functions.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Element end tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_end(sess, strm, 0, "/>");
		CHECK_EQUAL("/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_element_end(sess, strm, 0, "/>");
		CHECK_EQUAL("/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_element_end(sess, strm, 0, "/>");
		CHECK_EQUAL("\n/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_element_end(sess, strm, 0, "/>");
		CHECK_EQUAL("\n/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_end(sess, strm, 0, ">");
		CHECK_EQUAL(">\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_element_end(sess, strm, 0, ">");
		CHECK_EQUAL(">\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_element_end(sess, strm, 0, ">");
		CHECK_EQUAL("\n\t>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_element_end(sess, strm, 0, ">");
		CHECK_EQUAL("\n\t>\n", buffer);
	}


	/**********************************************************************
	 * Attribute tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Attribute_OnLevel0)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(strm, 0, "ProjectType", "Visual C++");
		CHECK_EQUAL("\nProjectType=\"Visual C++\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_OnLevel3)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(strm, 3, "ProjectType", "Visual C++");
		CHECK_EQUAL("\n\t\t\tProjectType=\"Visual C++\"", buffer);
	}
}
