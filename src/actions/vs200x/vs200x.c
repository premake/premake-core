/**
 * \file   vs200x.c
 * \brief  General purpose Visual Studio support functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "premake.h"
#include "vs200x.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/env.h"
#include "base/error.h"


/**
 * Write an XML attribute, adjusting for the differing Visual Studio formats.
 * \param   strm         The output stream, the attribute will be written here.
 * \param   indent_size  How far to indent (with tabs) the attribute.
 * \param   name    The attribute name.
 * \param   value   The attribute value; may contain printf-style formatting codes.
 * \returns OKAY if successful.
 */
int vs200x_attribute(Stream strm, int indent_size, const char* name, const char* value, ...)
{
	va_list args;
	char* buffer;
	int z = OKAY;

	z |= stream_writeline(strm, "");
	z |= stream_write_n(strm, "\t", indent_size);
	z |= stream_write(strm, "%s=\"", name);

	buffer = buffers_next();
	va_start(args, value);
	vsprintf(buffer, value, args);
	z |= stream_write_escaped(strm, buffer);
	va_end(args);
	
	z |= stream_write(strm, "\"");
	return z;
}


/**
 * Write an XML attribute containing a list of values, adjusting for the differing Visual Studio formats.
 * \param   strm         The output stream, the attribute will be written here.
 * \param   indent_size  How far to indent (with tabs) the attribute.
 * \param   name    The attribute name.
 * \param   values   The attribute list value.
 * \returns OKAY if successful.
 */
int vs200x_list_attribute(Stream strm, int indent_size, const char* name, Strings values)
{
	int z = OKAY;
	
	z |= stream_writeline(strm, "");
	z |= stream_write_n(strm, "\t", indent_size);
	z |= stream_write(strm, "%s=", name);
	z |= stream_write_strings(strm, values, "\"", "", "", ";", "\"", stream_write_escaped);
	return z;
}


/**
 * Write the ending part of an XML tag, adjust for the differing Visual Studio formats.
 * \param   strm    The output stream.
 * \param   level   The XML element nesting level.
 * \param   markup  The end tag markup.
 * \returns OKAY if successful.
 */
int vs200x_element_end(Stream strm, int level, const char* markup)
{
	int z, version;
	
	version = vs200x_get_target_version();
	if (version >= 2005)
	{
		z = stream_writeline(strm, "");
		if (markup[0] == '>')
		{
			level++;
		}
		z |= stream_write_n(strm, "\t", level);
		z |= stream_writeline(strm, "%s", markup);
	}
	else
	{
		z = stream_writeline(strm, markup);
	}
	return z;
}


/**
 * Return the Visual Studio version appropriate version of the string for a false
 * value. Before 2005 this was "FALSE", after it is "false".
 */
const char* vs200x_false(void)
{
	int version = vs200x_get_target_version();
	return (version < 2005) ? "FALSE" : "false";
}


/**
 * Converts the session action string to a Visual Studio version number.
 * \returns The Visual Studio version number corresponding to the current action.
 */
int vs200x_get_target_version(void)
{
	const char* action = env_get_action();
	if (cstr_eq(action, "vs2002"))
	{
		return 2002;
	}
	else if (cstr_eq(action, "vs2003"))
	{
		return 2003;
	}
	else if (cstr_eq(action, "vs2005"))
	{
		return 2005;
	}
	else if (cstr_eq(action, "vs2008"))
	{
		return 2008;
	}
	else
	{
		assert(0);
		return 0;
	}
}


/**
 * Return the appropriate file extension for a particular project.
 * \param   prj    The project object.
 * \returns The appropriate project file extension, based on the project settings.
 */
const char* vs200x_project_file_extension(Project prj)
{
	const char* language = project_get_language(prj);
	if (cstr_eq(language, "c") || cstr_eq(language, "c++"))
	{
		return ".vcproj";
	}
	else
	{
		error_set("unsupported language '%s'", language); 
		return NULL;
	}
}


/**
 * Returns the Visual Studio GUID for a particular project type.
 * \param   language   The programming language used in the project.
 * \returns The GUID corresponding the programming language.
 */
const char* vs200x_tool_guid(const char* language)
{
	if (cstr_eq(language, "c") || cstr_eq(language, "c++"))
	{
		return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942";
	}
	else if (cstr_eq(language, "c#"))
	{
		return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC";
	}
	else
	{
		error_set("unsupported language '%s'", language); 
		return NULL;
	}
}


/**
 * Return the Visual Studio version appropriate version of the string for a true
 * value. Before 2005 this was "TRUE", after it is "true".
 */
const char* vs200x_true(void)
{
	int version = vs200x_get_target_version();
	return (version < 2005) ? "TRUE" : "true";
}
