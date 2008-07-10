/**
 * \file   unload_block_tests.cpp
 * \brief  Automated tests for configuration block unloading from the script environment.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "script/script_internal.h"
}


struct FxUnloadBlock
{
	lua_State* L;
	Script     script;
	Block      blk;

	FxUnloadBlock()
	{
		script = script_create();
		L = script_get_lua(script);

		blk = block_create();

		script_run_string(script,
			"solution('MySolution');"
			"  defines { 'DEBUG', 'DEBUG2' };"
			"  return configuration()");
	}

	~FxUnloadBlock()
	{
		block_destroy(blk);
		script_destroy(script);
	}
};


SUITE(unload)
{
	TEST_FIXTURE(FxUnloadBlock, UnloadBlock_UnloadsDefines)
	{
		unload_block(L, blk);
		Strings defines = block_get_values(blk, BlockDefines);
		CHECK(strings_size(defines) == 2);
		if (strings_size(defines) == 2) {
			CHECK_EQUAL("DEBUG",  strings_item(defines, 0));
			CHECK_EQUAL("DEBUG2", strings_item(defines, 1));
		}
	}
}
