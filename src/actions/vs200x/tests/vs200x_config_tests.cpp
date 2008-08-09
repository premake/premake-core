/**
 * \file   vs200x_config_tests.cpp
 * \brief  Automated tests for VS200x configuration settings processing.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/vs200x/vs200x_config.h"
#include "base/env.h"
}

SUITE(action)
{
	/*************************************************************************
	 * Character set tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"2\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"2\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"1\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"1\"", buffer);
	}


	/*************************************************************************
	 * Defines tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsDefines_Empty_OnNoSymbols)
	{
		env_set_action("vs2002");
		vs200x_config_defines(strm, prj);
		CHECK_EQUAL("", buffer);
	}

	TEST_FIXTURE(FxAction, VsDefines_SemiSplitList)
	{
		env_set_action("vs2002");
		char* values[] = { "DEFINE0", "DEFINE1", "DEFINE2", NULL };
		SetConfigField(prj, BlockDefines, values);
		vs200x_config_defines(strm, prj);
		CHECK_EQUAL("\n\t\t\t\tPreprocessorDefinitions=\"DEFINE0;DEFINE1;DEFINE2\"", buffer);
	}
}
