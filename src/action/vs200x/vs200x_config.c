/**
 * \file   vs200x_config.c
 * \brief  Visual Studio 200x configuration generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "vs200x.h"
#include "vs200x_config.h"


int vs200x_config_character_set(Session sess, Stream strm)
{
	int version = vs200x_get_target_version(sess);
	return vs200x_attribute(strm, 3, "CharacterSet", version > 2003 ? "1" : "2");
}


int vs200x_config_detect_64bit_portability(Session sess, Stream strm, Project prj)
{
	int version = vs200x_get_target_version(sess);
	UNUSED(prj);
	if (version < 2008)
	{
		return vs200x_attribute(strm, 4, "Detect64BitPortabilityProblems", vs200x_true(sess));
	}
	return OKAY;
}


int vs200x_config_runtime_type_info(Session sess, Stream strm, Project prj)
{
	int version = vs200x_get_target_version(sess);
	UNUSED(prj);
	if (version < 2005)
	{
		return vs200x_attribute(strm, 4, "RuntimeTypeInfo", vs200x_true(sess));
	}
	return OKAY;
}


int vs200x_config_use_precompiled_header(Session sess, Stream strm, Project prj)
{
	int version = vs200x_get_target_version(sess);
	UNUSED(prj);
	return vs200x_attribute(strm, 4, "UsePrecompiledHeader", (version > 2003) ? "0" : "2");
}
