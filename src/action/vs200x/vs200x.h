/**
 * \file   vs200x.h
 * \brief  General purpose Visual Studio support functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_H)
#define PREMAKE_VS200X_H

#include "session/session.h"

int         vs200x_attribute(Stream strm, int indent_size, const char* name, const char* value, ...);
int         vs200x_element_end(Session sess, Stream strm, int level, const char* markup);
const char* vs200x_false(Session sess);
int         vs200x_get_target_version(Session sess);
const char* vs200x_project_file_extension(Project prj);
const char* vs200x_tool_guid(const char* language);
const char* vs200x_true(Session sess);

#endif

