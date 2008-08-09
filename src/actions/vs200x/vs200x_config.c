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


/**
 * Write out the list of preprocessor symbols as defined by the configuration.
 * This entry is only written if there are values to write.
 */
int vs200x_config_defines(Stream strm, Project prj)
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
