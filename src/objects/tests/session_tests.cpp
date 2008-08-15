/**
 * \file   session_tests.cpp
 * \brief  Automated test for the Session class.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "objects/session.h"
#include "base/base.h"
#include "base/error.h"
#include "base/env.h"
}


/**************************************************************************
 * Support functions for Session object testing
 **************************************************************************/

#define FAIL_SLN_PARAM  (1)
#define FAIL_PRJ_PARAM  (2)

static SessionFeatures features = {
	{ "console", NULL },
	{ "c", "c++", NULL },
};


static int num_solution_calls;
static int num_project_calls;
static int num_config_calls;
static const char* last_config_filter;


static int test_solution_okay(Solution sln, Stream strm)
{
	UNUSED(sln);  UNUSED(strm);
	num_solution_calls++;
	return OKAY;
}

static int test_solution_fail(Solution sln, Stream strm)
{
	UNUSED(sln);  UNUSED(strm);
	return !OKAY;
}

static int test_project_okay(Project prj, Stream strm)
{
	UNUSED(prj);  UNUSED(strm);
	num_project_calls++;
	return OKAY;
}

static int test_project_fail(Project prj, Stream strm)
{
	UNUSED(prj);  UNUSED(strm);
	return !OKAY;
}

static int test_config_okay(Project prj, Stream strm)
{
	UNUSED(strm);
	num_config_calls++;
	last_config_filter = project_get_config(prj);
	return OKAY;
}


struct FxSession
{
	Session sess;
	Solution sln;
	Project prj;

	FxSession()
	{
		sess = session_create();
		num_solution_calls = 0;
		num_project_calls = 0;
		num_config_calls = 0;
		last_config_filter = NULL;
	}

	~FxSession()
	{
		session_destroy(sess);
		error_clear();
	}

	Solution AddSolution()
	{
		sln = solution_create();
		session_add_solution(sess, sln);
		solution_set_name(sln, "MySolution");
		return sln;
	}

	Project AddProject()
	{
		prj = project_create();
		solution_add_project(sln, prj);
		project_set_name(prj, "MyProject");
		project_set_kind(prj, "Console");
		project_set_language(prj, "C++");
		return prj;
	}
};


SUITE(session)
{
	/**********************************************************************
	 * Initial state checks
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Create_ReturnsObject_OnSuccess)
	{
		CHECK(sess != NULL);
	}


	/**********************************************************************
	 * Solution containment tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, NumSolutions_ReturnsZero_OnCreate)
	{
		int n = session_num_solutions(sess);
		CHECK(n == 0);
	}

	TEST_FIXTURE(FxSession, NumSolutions_ReturnsOne_OnAddSolution)
	{
		AddSolution();
		int n = session_num_solutions(sess);
		CHECK(n == 1);
	}

	TEST_FIXTURE(FxSession, GetSolution_ReturnsSolution_OnAddSolution)
	{
		Solution sln = AddSolution();
		CHECK(sln == session_get_solution(sess, 0));
	}


	/**********************************************************************
	 * Object enumeration tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Enumerate_ReturnsOkay_OnSuccess)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		int result = session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsAllSolutionFuncs_OnSolution)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_okay, test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsSolutionFunc_OnEachSolution)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_solution_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_ReturnsNotOkay_OnSolutionError)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_fail, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		int result = session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxSession, Enumerate_StopsProcessing_OnSolutionError)
	{
		SessionSolutionCallback sln_funcs[] = { test_solution_fail, test_solution_okay, NULL };
		SessionProjectCallback  prj_funcs[] = { NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddSolution();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_solution_calls == 0);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsAllProjectFuncs_OnProject)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { test_project_okay, test_project_okay, NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddProject();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_project_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsProjectFunc_OnEachProject)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { test_project_okay, NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddProject();
		AddProject();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_project_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_ReturnsNotOkay_OnProjectError)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { test_project_fail, NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddProject();
		int result = session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(result != OKAY);
	}

	TEST_FIXTURE(FxSession, Enumerate_StopsProcessing_OnProjectError)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { test_project_fail, test_project_okay, NULL };
		SessionProjectCallback  cfg_funcs[] = { NULL };
		AddSolution();
		AddProject();
		AddProject();
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_project_calls == 0);
	}

	TEST_FIXTURE(FxSession, Enumerate_CallsAllConfigFuncs_OnConfig)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { session_enumerate_configurations, NULL };
		SessionProjectCallback  cfg_funcs[] = { test_config_okay, test_config_okay, NULL };
		AddSolution();
		AddProject();
		solution_add_config(sln, "Debug");
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK(num_config_calls == 2);
	}

	TEST_FIXTURE(FxSession, Enumerate_SetsConfigFilter_OnConfig)
	{
		SessionSolutionCallback sln_funcs[] = { NULL };
		SessionProjectCallback  prj_funcs[] = { session_enumerate_configurations, NULL };
		SessionProjectCallback  cfg_funcs[] = { test_config_okay, test_config_okay, NULL };
		AddSolution();
		AddProject();
		solution_add_config(sln, "Debug");
		session_enumerate_objects(sess, sln_funcs, prj_funcs, cfg_funcs);
		CHECK_EQUAL("Debug", last_config_filter);
	}


	/**********************************************************************
	 * Session validation tests
	 **********************************************************************/

	TEST_FIXTURE(FxSession, Validate_ReturnsOkay_OnNoSolutions)
	{
		int result = session_validate(sess, &features);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxSession, Validate_ReturnsOkay_OnAllsWell)
	{
		AddSolution();
		AddProject();
		project_set_language(prj, "c++");
		int result = session_validate(sess, &features);
		CHECK(result == OKAY);
	}

	TEST_FIXTURE(FxSession, Validate_NotOkay_OnEmptySolution)
	{
		AddSolution();
		int result = session_validate(sess, &features);
		CHECK(result != OKAY);
		CHECK_EQUAL("no projects defined for solution 'MySolution'", error_get());
	}

	TEST_FIXTURE(FxSession, Validate_NotOkay_OnNullKind)
	{
		AddSolution();
		AddProject();
		project_set_kind(prj, NULL);
		int result = session_validate(sess, &features);
		CHECK(result != OKAY);
		CHECK_EQUAL("project 'MyProject' needs a kind", error_get());
	}

	TEST_FIXTURE(FxSession, Validate_NotOkay_OnUnsupportedKind)
	{
		AddSolution();
		AddProject();
		project_set_kind(prj, "nonesuch");
		int result = session_validate(sess, &features);
		CHECK(result != OKAY);
		CHECK_EQUAL("nonesuch projects are not supported by this action", error_get());
	}

	TEST_FIXTURE(FxSession, Validate_NotOkay_OnNullLanguage)
	{
		AddSolution();
		AddProject();
		project_set_language(prj, NULL);
		int result = session_validate(sess, &features);
		CHECK(result != OKAY);
		CHECK_EQUAL("project 'MyProject' needs a language", error_get());
	}

	TEST_FIXTURE(FxSession, Validate_NotOkay_OnUnsupportedLanguage)
	{
		AddSolution();
		AddProject();
		project_set_language(prj, "nonesuch");
		int result = session_validate(sess, &features);
		CHECK(result != OKAY);
		CHECK_EQUAL("nonesuch projects are not supported by this action", error_get());
	}
}

