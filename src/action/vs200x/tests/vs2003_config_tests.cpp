/**
 * \file   vs2003_config_tests.cpp
 * \brief  Automated tests for VS2003 configuration processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x_config.h"
}

struct Fx2003Config : FxAction
{
	Fx2003Config()
	{
		session_set_action(sess, "vs2003");
	}
};


SUITE(action)
{
	TEST_FIXTURE(Fx2003Config, CharacterSet_Default)
	{
		vs200x_config_character_set(sess);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"2\"", buffer);
	}
}
