/**
 * \file   vs200x_tests.h
 * \brief  Standard test fixtures for Visual Studio.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

struct FxVs200x
{
	Session  sess;
	Stream   strm;
	Solution sln;
	Project  prj;
	char     buffer[8192];

	FxVs200x()
	{
		sess = session_create();

		strm = stream_create_null();
		stream_set_buffer(strm, buffer);

		sln = solution_create();
		solution_set_name(sln, "MySolution");
		solution_set_base_dir(sln, "/Root");
		solution_add_config_name(sln, "Debug");
		solution_add_config_name(sln, "Release");

		prj = project_create();
		project_set_name(prj, "MyProject");
		project_set_base_dir(prj, "/Root");
		project_set_location(prj, "ProjectFolder");
		project_set_guid(prj, "AE2461B7-236F-4278-81D3-F0D476F9A4C0");
		solution_add_project(sln, prj);
	}

	~FxVs200x()
	{
		solution_destroy(sln);
		stream_destroy(strm);
		session_destroy(sess);
	}
};
