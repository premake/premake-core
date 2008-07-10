/**
 * \file   vs200x_xml_tests.cpp
 * \brief  Automated tests for Visual Studio XML output functions.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/vs200x/vs200x.h"
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

	TEST_FIXTURE(FxAction, Attribute_IsEscaped)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(strm, 1, "PreprocessorSymbols", "DEBUG;MSG=\"Hello\";TRACE");
		CHECK_EQUAL("\n\tPreprocessorSymbols=\"DEBUG;MSG=&quot;Hello&quot;;TRACE\"", buffer);
	}

	TEST_FIXTURE(FxAction, AttributeList_OnLevel0)
	{
		const char* values[] = { "VALUE0", "VALUE1", "VALUE2", NULL };
		Strings strs = strings_create_from_array(values);
		vs200x_list_attribute(strm, 0, "Values", strs);
		CHECK_EQUAL("\nValues=\"VALUE0;VALUE1;VALUE2\"", buffer);
		strings_destroy(strs);
	}

	TEST_FIXTURE(FxAction, AttributeList_IsEscaped)
	{
		const char* values[] = { "VALUE0", "VALUE1=\"Hello\"", "VALUE2", NULL };
		Strings strs = strings_create_from_array(values);
		vs200x_list_attribute(strm, 0, "Values", strs);
		CHECK_EQUAL("\nValues=\"VALUE0;VALUE1=&quot;Hello&quot;;VALUE2\"", buffer);
		strings_destroy(strs);
	}

}
