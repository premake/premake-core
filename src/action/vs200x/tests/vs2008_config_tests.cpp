/**
 * \file   vs2008_config_tests.cpp
 * \brief  Automated tests for VS2008 configuration processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x_config.h"
}

struct Fx2008Config : FxAction
{
	Fx2008Config()
	{
		session_set_action(sess, "vs2008");
	}
};


SUITE(action)
{
	TEST_FIXTURE(Fx2008Config, CharacterSet_Default)
	{
		vs200x_config_character_set(sess, strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"1\"", buffer);
	}
}
