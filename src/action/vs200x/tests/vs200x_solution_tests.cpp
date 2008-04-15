/**
 * \file   vs200x_solution_tests.cpp
 * \brief  Automated tests for VS200x solution processing.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "action/vs200x/vs200x_solution.h"
}

struct FxVs200xSln
{
	Session sess;
	Stream strm;
	Solution sln;
	char buffer[8192];

	FxVs200xSln()
	{
		sess = session_create();

		strm = stream_create_null();
		stream_set_buffer(strm, buffer);

		sln = solution_create();
		solution_set_name(sln, "MySolution");
		solution_set_base_dir(sln, "/Root");
	}

	~FxVs200xSln()
	{
		solution_destroy(sln);
		stream_destroy(strm);
		session_destroy(sess);
	}

	Project AddProject()
	{
		Project prj = project_create();
		project_set_name(prj, "MyProject");
		project_set_base_dir(prj, "/Root");
		project_set_guid(prj, "AE2461B7-236F-4278-81D3-F0D476F9A4C0");
		solution_add_project(sln, prj);
		return prj;
	}
};


SUITE(action)
{
	/**********************************************************************
	 * Signature tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2002)
	{
		session_set_action(sess, "vs2002");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277Microsoft Visual Studio Solution File, Format Version 7.00\r\n",
			buffer);
	}

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2003)
	{
		session_set_action(sess, "vs2003");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277Microsoft Visual Studio Solution File, Format Version 8.00\r\n",
			buffer);
	}

	TEST_FIXTURE(FxVs200xSln, Signature_IsCorrect_OnVs2005)
	{
		session_set_action(sess, "vs2005");
		vs200x_solution_signature(sess, sln, strm);
		CHECK_EQUAL(
			"\357\273\277\r\n"
			"Microsoft Visual Studio Solution File, Format Version 9.00\r\n"
			"# Visual Studio 2005\r\n",
			buffer);
	}


	/**********************************************************************
	 * Project entry tests
	 **********************************************************************/

	TEST_FIXTURE(FxVs200xSln, ProjectEntry_IsCorrect_OnCppProject)
	{
		AddProject();
		vs200x_solution_projects(sess, sln, strm);
		CHECK_EQUAL(
			"Project(\"{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}\") = \"MyProject\", \"MyProject.vcproj\", \"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"EndProject\n",
			buffer);
	}

	TEST_FIXTURE(FxVs200xSln, ProjectEntry_UsesRelativePath)
	{
		Project prj = AddProject();
		project_set_location(prj, "ProjectFolder");
		vs200x_solution_projects(sess, sln, strm);			
		CHECK_EQUAL(
			"Project(\"{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}\") = \"MyProject\", \"ProjectFolder\\MyProject.vcproj\", \"{AE2461B7-236F-4278-81D3-F0D476F9A4C0}\"\n"
			"EndProject\n",
			buffer);
	}

}
