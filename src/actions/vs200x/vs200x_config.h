/**
 * \file   vs200x_config.h
 * \brief  Visual Studio 200x configuration generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_CONFIG_H)
#define PREMAKE_VS200X_CONFIG_H

int vs200x_config_character_set(Stream strm);
int vs200x_config_defines(Stream strm, Project prj);
int vs200x_config_detect_64bit_portability(Stream strm);
int vs200x_config_runtime_type_info(Stream strm);
int vs200x_config_use_precompiled_header(Stream strm);

#endif
