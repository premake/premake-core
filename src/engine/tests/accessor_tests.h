/**
 * \file   accessor_tests.h
 * \brief  Common fixture for accessor function tests.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "testing/testing.h"
extern "C" {
#include "engine/session.h"
#include "base/error.h"
}


struct FxAccessor
{
	Session sess;

	FxAccessor()
	{
		sess = session_create();
		session_run_string(sess,
			"sln = solution 'MySolution';"
			"prj = project 'MyProject';");
	}

	~FxAccessor()
	{
		session_destroy(sess);
		error_clear();
	}
};
