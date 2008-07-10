/**
 * \file   make_config_tests.cpp
 * \brief  Automated tests for makefile configuration block processing.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/make/make_project.h"
#include "platform/platform.h"
}

SUITE(action)
{
	/**********************************************************************
	 * CPPFLAGS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeCppFlags_Defaults)
	{
		make_project_config_cppflags(sess, prj, strm);
		CHECK_EQUAL(
			"   CPPFLAGS += -MMD\n",
			buffer);
	}

	TEST_FIXTURE(FxAction, MakeCppFlags_WithDefines)
	{
		char* defines[] = { "DEFINE0", "DEFINE1", NULL};
		SetConfigField(prj, BlockDefines, defines);
		make_project_config_cppflags(sess, prj, strm);
		CHECK_EQUAL(
			"   CPPFLAGS += -MMD -D \"DEFINE0\" -D \"DEFINE1\"\n",
			buffer);
	}


	/**********************************************************************
	 * CFLAGS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_CFlags)
	{
		make_project_config_cflags(sess, prj, strm);
		CHECK_EQUAL(
			"   CFLAGS   += $(CPPFLAGS) $(ARCHFLAGS)\n",
			buffer);
	}


	/**********************************************************************
	 * CXXFLAGS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_CxxFlags)
	{
		make_project_config_cxxflags(sess, prj, strm);
		CHECK_EQUAL(
			"   CXXFLAGS += $(CFLAGS)\n",
			buffer);
	}


	/**********************************************************************
	 * LDDEPS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_LdDeps)
	{
		make_project_config_lddeps(sess, prj, strm);
		CHECK_EQUAL(
			"   LDDEPS   :=\n",
			buffer);
	}


	/**********************************************************************
	 * LDFLAGS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_LdFlags)
	{
		make_project_config_ldflags(sess, prj, strm);
		CHECK_EQUAL(
			"   LDFLAGS  +=\n",
			buffer);
	}


	/**********************************************************************
	 * OBJDIR tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_ObjDir)
	{
		make_project_config_objdir(sess, prj, strm);
		CHECK_EQUAL(
			"   OBJDIR   := obj/Debug\n",
			buffer);
	}


	/**********************************************************************
	 * OUTFILE tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_OutFile)
	{
		platform_set(MacOSX);
		make_project_config_outfile(sess, prj, strm);
		CHECK_EQUAL(
			"   OUTFILE  := $(OUTDIR)/MyProject\n",
			buffer);
	}


	/**********************************************************************
	 * OUTDIR tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_OutDir)
	{
		make_project_config_outdir(sess, prj, strm);
		CHECK_EQUAL(
			"   OUTDIR   := .\n",
			buffer);
	}


	/**********************************************************************
	 * RESFLAGS tests
	 **********************************************************************/

	TEST_FIXTURE(FxAction, MakeProject_Config_ResFlags)
	{
		make_project_config_resflags(sess, prj, strm);
		CHECK_EQUAL(
			"   RESFLAGS +=\n",
			buffer);
	}
}
