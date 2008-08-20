/**
 * \file   vs200x_config.c
 * \brief  Visual Studio 200x configuration generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "vs200x.h"
#include "vs200x_config.h"


int vs200x_config_character_set(Stream strm)
{
	return vs200x_attribute(strm, 3, "CharacterSet", vs200x_get_target_version() > 2003 ? "1" : "2");
}


int vs200x_config_debug_information_format(Project prj, Stream strm)
{
	const char* value;
	if (!project_has_flag(prj, "Symbols"))
	{
		value = "0";
	}
	else if (project_has_flag(prj, "Managed") ||
	         project_has_flag(prj, "Optimize") ||
			 project_has_flag(prj, "OptimizeSize") ||
			 project_has_flag(prj, "OptimizeSpeed") ||
			 project_has_flag(prj, "NoEditAndContinue"))
	{
		value = "3";
	}
	else
	{
		value = "4";
	}

	return vs200x_attribute(strm, 4, "DebugInformationFormat", value);
}


/**
 * Write out the list of preprocessor symbols as defined by the configuration.
 * This entry is only written if there are values to write.
 */
int vs200x_config_defines(Project prj, Stream strm)
{
	Strings values = project_get_config_values(prj, BlockDefines);
	if (strings_size(values) > 0)
	{
		return vs200x_list_attribute(strm, 4, "PreprocessorDefinitions", values);
	}

	return OKAY;
}


int vs200x_config_detect_64bit_portability(Stream strm)
{
	if (vs200x_get_target_version() < 2008)
	{
		return vs200x_attribute(strm, 4, "Detect64BitPortabilityProblems", vs200x_true());
	}
	return OKAY;
}


int vs200x_config_generate_debug_information(Project prj, Stream strm)
{
	int z = OKAY;
	if (project_has_flag(prj, "Symbols"))
	{
		z |= vs200x_attribute(strm, 4, "GenerateDebugInformation", vs200x_true());
		z |= vs200x_attribute(strm, 4, "ProgramDatabaseFile", "$(OutDir)/%s.pdb", project_get_name(prj));
	}
	else
	{
		z |= vs200x_attribute(strm, 4, "GenerateDebugInformation", vs200x_false());
	}
	return z;
}


int vs200x_config_optimization(Project prj, Stream strm)
{
	const char* value;
	if (project_has_flag(prj, "Optimize"))
	{
		value = "3";
	} 
	else if (project_has_flag(prj, "OptimizeSize"))
	{
		value= "1";
	}
	else if (project_has_flag(prj, "OptimizeSpeed"))
	{
		value = "2";
	}
	else
	{
		value = "0";
	}
	return vs200x_attribute(strm, 4, "Optimization", value);
}


int vs200x_config_runtime_type_info(Stream strm)
{
	if (vs200x_get_target_version() < 2005)
	{
		return vs200x_attribute(strm, 4, "RuntimeTypeInfo", vs200x_true());
	}
	return OKAY;
}


int vs200x_config_use_precompiled_header(Stream strm)
{
	return vs200x_attribute(strm, 4, "UsePrecompiledHeader", vs200x_get_target_version() > 2003 ? "0" : "2");
}
