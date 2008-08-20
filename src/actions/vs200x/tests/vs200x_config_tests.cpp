/**
 * \file   vs200x_config_tests.cpp
 * \brief  Automated tests for VS200x configuration settings processing.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "actions/tests/action_tests.h"
extern "C" {
#include "actions/vs200x/vs200x_config.h"
#include "base/env.h"
}

SUITE(action)
{
	/*************************************************************************
	 * Character set tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2002)
	{
		env_set_action("vs2002");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"2\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2003)
	{
		env_set_action("vs2003");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"2\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2005)
	{
		env_set_action("vs2005");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"1\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsCharacterSet_Defaults_OnVs2008)
	{
		env_set_action("vs2008");
		vs200x_config_character_set(strm);
		CHECK_EQUAL("\n\t\t\tCharacterSet=\"1\"", buffer);
	}


	/*************************************************************************
	 * Debug information tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsDebugFormat_Is0_OnNoSymbols)
	{
		env_set_action("vs2002");
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"0\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is4_OnSymbols)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"4\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is3_OnSymbolsAndManaged)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", "Managed", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"3\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is3_OnSymbolsAndOptimize)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", "Optimize", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"3\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is3_OnSymbolsAndOptimizeSize)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", "OptimizeSize", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"3\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is3_OnSymbolsAndOptimizeSpeed)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", "OptimizeSpeed", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"3\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsDebugFormat_Is3_OnSymbolsAndNoEditAndContinue)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", "NoEditAndContinue", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_debug_information_format(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tDebugInformationFormat=\"3\"", buffer);
	}

	TEST_FIXTURE(FxAction, VCDebugInfo_IsOff_WithNoSymbols)
	{
		env_set_action("vs2002");
		vs200x_config_generate_debug_information(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tGenerateDebugInformation=\"FALSE\"", buffer);
	}

	TEST_FIXTURE(FxAction, VCDebugInfo_IsOn_WithSymbols)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Symbols", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_generate_debug_information(prj, strm);
		CHECK_EQUAL(
			"\n\t\t\t\tGenerateDebugInformation=\"TRUE\""
			"\n\t\t\t\tProgramDatabaseFile=\"$(OutDir)/My Project.pdb\"",
			buffer);
	}


	/*************************************************************************
	 * Defines tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsDefines_Empty_OnNoSymbols)
	{
		env_set_action("vs2002");
		vs200x_config_defines(prj, strm);
		CHECK_EQUAL("", buffer);
	}

	TEST_FIXTURE(FxAction, VsDefines_SemiSplitList)
	{
		env_set_action("vs2002");
		const char* values[] = { "DEFINE0", "DEFINE1", "DEFINE2", NULL };
		SetConfigField(prj, BlockDefines, values);
		vs200x_config_defines(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tPreprocessorDefinitions=\"DEFINE0;DEFINE1;DEFINE2\"", buffer);
	}


	/*************************************************************************
	 * Optimization tests
	 *************************************************************************/

	TEST_FIXTURE(FxAction, VsOptimization_Is0_OnNoOptimization)
	{
		env_set_action("vs2002");
		vs200x_config_optimization(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tOptimization=\"0\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsOptimization_Is1_OnOptimizeSize)
	{
		env_set_action("vs2002");
		const char* flags[] = { "OptimizeSize", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_optimization(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tOptimization=\"1\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsOptimization_Is2_OnOptimizeSpeed)
	{
		env_set_action("vs2002");
		const char* flags[] = { "OptimizeSpeed", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_optimization(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tOptimization=\"2\"", buffer);
	}

	TEST_FIXTURE(FxAction, VsOptimization_Is2_OnOptimize)
	{
		env_set_action("vs2002");
		const char* flags[] = { "Optimize", NULL };
		SetConfigField(prj, BlockFlags, flags);
		vs200x_config_optimization(prj, strm);
		CHECK_EQUAL("\n\t\t\t\tOptimization=\"3\"", buffer);
	}
}
