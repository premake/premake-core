/**
 * Implementations for Premake's `path.*` functions.
 */

#include "../premake_internal.h"


int pmk_path_getAbsolute(lua_State* L)
{
	const char* relativeTo = luaL_optstring(L, 2, NULL);
	return (pmk_mapStrings(L, 1, relativeTo, pmk_getAbsolutePath));
}


int pmk_path_getBaseName(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* path = luaL_checkstring(L, 1);
	pmk_getFileBaseName(buffer, path);
	lua_pushstring(L, buffer);
	return (1);
}


int pmk_path_getDirectory(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* path = luaL_checkstring(L, 1);
	pmk_getDirectory(buffer, path);
	lua_pushstring(L, buffer);
	return (1);
}


int pmk_path_getName(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* path = luaL_checkstring(L, 1);
	pmk_getFileName(buffer, path);
	lua_pushstring(L, buffer);
	return (1);
}


int pmk_path_getKind(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	int kind = pmk_pathKind(path);
	switch (kind)
	{
	case PMK_PATH_KIND_UNKNOWN:
		lua_pushstring(L, "unknown");
		break;
	case PMK_PATH_ABSOLUTE:
		lua_pushstring(L, "absolute");
		break;
	case PMK_PATH_RELATIVE:
		lua_pushstring(L, "relative");
		break;
	}

	return (1);
}


int pmk_path_getRelative(lua_State* L)
{
	const char* basePath = luaL_checkstring(L, 1);
	return (pmk_mapStrings(L, 2, basePath, pmk_getRelativePath));
}


int pmk_path_getRelativeFile(lua_State* L)
{
	const char* basePath = luaL_checkstring(L, 1);
	return (pmk_mapStrings(L, 2, basePath, pmk_getRelativeFile));
}


int pmk_path_isAbsolute(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushboolean(L, pmk_isAbsolutePath(path));
	return (1);
}


int pmk_path_join(lua_State* L)
{
	char buffer[PATH_MAX] = { '\0' };

	int argc = lua_gettop(L);

	for (int i = 1; i <= argc; ++i) {
		if (lua_isnil(L, i))
			continue;

		const char* part = luaL_checkstring(L, i);
		pmk_joinPath(buffer, part);
	}

	lua_pushstring(L, buffer);
	return (1);
}


int pmk_path_normalize(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* path = luaL_checkstring(L, 1);
	pmk_normalize(buffer, path);
	lua_pushstring(L, buffer);
	return (1);
}


int pmk_path_translate(lua_State* L)
{
	const char* separator = luaL_optstring(L, 2, "\\");
	return (pmk_mapStrings(L, 1, separator, pmk_translatePath));
}
