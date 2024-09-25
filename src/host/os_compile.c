/**
 * \file   os_compile.c
 * \brief  Compile lua source.
 * \author Copyright (c) 2002-2012 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "lundump.h"
#include "lstate.h"

extern int original_luaL_loadfilex(lua_State* L, const char* filename, const char* mode);

static int writer(lua_State* L, const void* p, size_t size, void* u)
{
	UNUSED(L);
	return (fwrite(p, size, 1, (FILE*)u) != 1) && (size != 0);
}

int os_compile(lua_State* L)
{
	const char* input = luaL_checkstring(L, 1);
	const char* output = luaL_checkstring(L, 2);
	lua_State* P = luaL_newstate();

	if (original_luaL_loadfilex(P, input, NULL) != LUA_OK)
	{
		const char* msg = lua_tostring(P, -1);
		if (msg == NULL)
			msg = "(error with no message)";

		lua_pushnil(L);
		lua_pushfstring(L, "Unable to compile '%s': %s", input, msg);

		lua_close(P);
		return 2;
	}
	else
	{
		FILE* outputFile = (output == NULL) ? stdout : fopen(output, "wb");
		if (outputFile == NULL)
		{
			lua_close(P);

			lua_pushnil(L);
			lua_pushfstring(L, "unable to write to '%s'", output);
			return 2;
		}

		lua_dump(P, writer, outputFile, false);
		fclose(outputFile);

		lua_close(P);
		lua_pushboolean(L, 1);
		return 1;
	}
}
