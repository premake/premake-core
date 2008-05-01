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
	 * Element tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Element_OnLevel0)
	{
		session_set_action(sess, "vs2002");
		vs200x_element(sess, 0, "VisualStudioProject");
		CHECK_EQUAL("<VisualStudioProject>\n", buffer);
	}

	TEST_FIXTURE(FxAction, Element_OnLevel1)
	{
		session_set_action(sess, "vs2002");
		vs200x_element(sess, 1, "VisualStudioProject");
		CHECK_EQUAL("\t<VisualStudioProject>\n", buffer);
	}

	/**********************************************************************
	 * Element start tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, ElementStart_OnLevel0)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_start(sess, 0, "VisualStudioProject");
		CHECK_EQUAL("<VisualStudioProject", buffer);
	}

	TEST_FIXTURE(FxAction, ElementStart_OnLevel1)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_start(sess, 1, "VisualStudioProject");
		CHECK_EQUAL("\t<VisualStudioProject", buffer);
	}


	/**********************************************************************
	 * Element end tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_end(sess, 0, "/>");
		CHECK_EQUAL("/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_element_end(sess, 0, "/>");
		CHECK_EQUAL("/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_element_end(sess, 0, "/>");
		CHECK_EQUAL("\n/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_SlashBracket_Vs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_element_end(sess, 0, "/>");
		CHECK_EQUAL("\n/>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_element_end(sess, 0, ">");
		CHECK_EQUAL(">\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_element_end(sess, 0, ">");
		CHECK_EQUAL(">\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_element_end(sess, 0, ">");
		CHECK_EQUAL("\n\t>\n", buffer);
	}

	TEST_FIXTURE(FxAction, ElementEnd_Bracket_Vs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_element_end(sess, 0, ">");
		CHECK_EQUAL("\n\t>\n", buffer);
	}


	/**********************************************************************
	 * Attribute tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Attribute_OnLevel0)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(sess, 0, "ProjectType", "Visual C++");
		CHECK_EQUAL("\n\tProjectType=\"Visual C++\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_OnLevel1)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(sess, 1, "ProjectType", "Visual C++");
		CHECK_EQUAL("\n\t\tProjectType=\"Visual C++\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_BooleanValue_OnVs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_attribute(sess, 0, "RuntimeTypeInfo", "true");
		CHECK_EQUAL("\n\tRuntimeTypeInfo=\"TRUE\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_BooleanValue_OnVs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_attribute(sess, 0, "RuntimeTypeInfo", "true");
		CHECK_EQUAL("\n\tRuntimeTypeInfo=\"TRUE\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_BooleanValue_OnVs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_attribute(sess, 0, "RuntimeTypeInfo", "true");
		CHECK_EQUAL("\n\tRuntimeTypeInfo=\"true\"", buffer);
	}

	TEST_FIXTURE(FxAction, Attribute_BooleanValue_OnVs2008)
	{
		session_set_action(sess, "vs2008");
		vs200x_attribute(sess, 0, "RuntimeTypeInfo", "true");
		CHECK_EQUAL("\n\tRuntimeTypeInfo=\"true\"", buffer);
	}
}
