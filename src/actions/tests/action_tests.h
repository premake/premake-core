/**
 * \file   action_tests.h
 * \brief  Common test fixtures for all action tests.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "testing/testing.h"
extern "C" {
#include "session/session.h"
#include "project/project.h"
}

struct FxAction
{
	Session  sess;
	Stream   strm;
	Solution sln;
	Filter   flt;
	Project  prj;
	char     buffer[8192];

	FxAction()
	{
		sess = session_create();

		strm = stream_create_null();
		stream_set_buffer(strm, buffer);
		session_set_active_stream(sess, strm);

		sln = solution_create();
		session_add_solution(sess, sln);
		solution_set_name(sln, "MySolution");
		solution_set_base_dir(sln, "/Root");
		solution_add_config(sln, "Debug");
		solution_add_config(sln, "Release");

		prj = project_create();
		solution_add_project(sln, prj);
		project_set_name(prj, "MyProject");
		project_set_base_dir(prj, "/Root");
		project_set_location(prj, "ProjectFolder");
		project_set_guid(prj, "AE2461B7-236F-4278-81D3-F0D476F9A4C0");
		project_set_language(prj, "c++");

		flt = filter_create();
		filter_set_value(flt, FilterConfig, "Debug");
		project_set_filter(prj, flt);
	}

	~FxAction()
	{
		stream_destroy(strm);
		session_destroy(sess);
		filter_destroy(flt);
	}


	void SetField(Project prj, enum ProjectField index, char** values)
	{
		Strings strs = strings_create();
		for (char** value = values; (*value) != NULL; ++value)
		{
			strings_add(strs, *value);
		}

		project_set_values(prj, index, strs);
	}

	void SetConfigField(Project prj, enum BlockField index, char** values)
	{
		Strings strs = strings_create();
		for (char** value = values; (*value) != NULL; ++value)
		{
			strings_add(strs, *value);
		}

		Block blk = block_create();
		block_set_values(blk, index, strs);

		Blocks blks = project_get_blocks(prj);
		blocks_add(blks, blk);
	}
};
