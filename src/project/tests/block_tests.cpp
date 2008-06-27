/**
 * \file   block_tests.cpp
 * \brief  Automated tests for the configuration blocks API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "project/solution.h"
#include "project/project.h"
#include "project/block.h"
}


struct FxBlock
{
	Solution sln;
	Project prj;
	Block blk;

	FxBlock()
	{
		sln = solution_create();
		prj = project_create();
		blk = block_create();
	}

	~FxBlock()
	{
		block_destroy(blk);
		project_destroy(prj);
		solution_destroy(sln);
	}
};


SUITE(project)
{
	TEST_FIXTURE(FxBlock, Create_ReturnsObject_OnSuccess)
	{
		CHECK(blk != NULL);
	}
}


