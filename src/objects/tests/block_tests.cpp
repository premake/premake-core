/**
 * \file   block_tests.cpp
 * \brief  Automated tests for the configuration blocks API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "objects/solution.h"
#include "objects/block.h"
#include "base/env.h"
}


struct FxBlock
{
	Block blk;
	Strings terms;

	FxBlock()
	{
		blk = block_create();
		terms = strings_create();
		block_set_values(blk, BlockTerms, terms);
	}

	~FxBlock()
	{
		block_destroy(blk);
	}
};


SUITE(project)
{
	TEST_FIXTURE(FxBlock, Create_ReturnsObject_OnSuccess)
	{
		CHECK(blk != NULL);
	}

	TEST_FIXTURE(FxBlock, AppliesTo_CanMatchOS)
	{
		env_set_os(MacOSX);
		strings_add(terms, "macosx");
		CHECK(block_applies_to(blk, "Debug"));
	}

	TEST_FIXTURE(FxBlock, AppliesTo_CanMatchAction)
	{
		env_set_action("vs2005");
		strings_add(terms, "vs2005");
		CHECK(block_applies_to(blk, "Debug"));
	}

	TEST_FIXTURE(FxBlock, AppliesTo_CanMatchConfig)
	{
		strings_add(terms, "debug");
		CHECK(block_applies_to(blk, "Debug"));
	}

	TEST_FIXTURE(FxBlock, AppliesTo_AcceptsPatterns)
	{
		strings_add(terms, "Debug .*");
		CHECK(block_applies_to(blk, "Debug DLL"));
	}

	TEST_FIXTURE(FxBlock, AppliesTo_AcceptsNullConfig)
	{
		CHECK(block_applies_to(blk, NULL));
	}

	TEST_FIXTURE(FxBlock, AppliesTo_ReturnsFalse_OnUnmatchedTerm)
	{
		strings_add(terms, "NoSuchKeyword");
		CHECK(!block_applies_to(blk, "Debug"));
	}
}


