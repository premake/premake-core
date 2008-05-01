/**
 * \file   vs200x_tests.cpp
 * \brief  Automated tests for VS200x support functions.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "action/tests/action_tests.h"
extern "C" {
#include "action/vs200x/vs200x.h"
}


SUITE(action)
{
	/**********************************************************************
	 * Language GUID tests
	 **********************************************************************/

	TEST(ToolGuid_ReturnsCorrectGUID_OnC)
	{
		const char* result = vs200x_tool_guid("c");
		CHECK_EQUAL("8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942", result);
	}

	TEST(ToolGuid_ReturnsCorrectGUID_OnCpp)
	{
		const char* result = vs200x_tool_guid("c++");
		CHECK_EQUAL("8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942", result);
	}

	TEST(ToolGuid_ReturnsCorrectGUID_OnCSharp)
	{
		const char* result = vs200x_tool_guid("c#");
		CHECK_EQUAL("FAE04EC0-301F-11D3-BF4B-00C04F79EFBC", result);
	}


	/**********************************************************************
	 * Language file extensions
	 **********************************************************************/

	TEST_FIXTURE(FxAction, ProjectExtension_IsVcproj_ForC)
	{
		project_set_language(prj, "c");
		const char* result = vs200x_project_file_extension(prj);
		CHECK_EQUAL(".vcproj", result);
	}


	/**********************************************************************
	 * Session validation
	 **********************************************************************/

	TEST_FIXTURE(FxAction, Vs200xValidation_ReturnsNotOkay_OnUnknownLanguage)
	{
		project_set_language(prj, "nonesuch");
		int result = vs200x_validate_session(sess);
		CHECK(result != OKAY);
	}
}
