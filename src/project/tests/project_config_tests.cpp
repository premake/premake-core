/**
 * \file   project_config_tests.cpp
 * \brief  Automated tests for the project configuration data API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
#include "project/project.h"
#include "project/project_internal.h"
}


struct FxPrjConfig
{
	Solution sln;
	Fields   sln_blk0_fields;

	Project prj;
	Fields  prj_blk0_fields;

	FxPrjConfig()
	{
		Blocks blks;
		Block  blk;
		Strings strs;

		sln = solution_create();
		prj = project_create();
		solution_add_project(sln, prj);

		blks = solution_get_blocks(sln);
		blk  = block_create();
		blocks_add(blks, blk);
		sln_blk0_fields = block_get_fields(blk);

		strs = strings_create();
		strings_add(strs, "SLN");
		fields_set_values(sln_blk0_fields, BlockDefines, strs);

		blks = project_get_blocks(prj);
		blk  = block_create();
		blocks_add(blks, blk);
		prj_blk0_fields = block_get_fields(blk);

		strs = strings_create();
		strings_add(strs, "PRJ");
		fields_set_values(prj_blk0_fields, BlockDefines, strs);
	}

	~FxPrjConfig()
	{
		solution_destroy(sln);
	}
};


SUITE(project_config)
{
	TEST_FIXTURE(FxPrjConfig, GetValues_GetsFromBoth)
	{
		Strings strs = project_get_config_values(prj, BlockDefines);
		CHECK(strings_size(strs) == 2);
		if (strings_size(strs) == 2)
		{
			CHECK_EQUAL("SLN", strings_item(strs, 0));
			CHECK_EQUAL("PRJ", strings_item(strs, 1));
		}
	}
}

