/**
 * Implementations for Premake's `os.*` functions.
 */

#include "../premake_internal.h"


int pmk_os_chdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	if (pmk_chdir(path)) {
		lua_pushboolean(L, 1);
		return (1);
	} else {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to switch to directory '%s'", path);
		return (2);
	}
}


int pmk_os_getCwd(lua_State* L)
{
	char buffer[PATH_MAX];

	if (pmk_getCwd(buffer)) {
		lua_pushstring(L, buffer);
		return (1);
	}

	return (0);
}


int pmk_os_isFile(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);
	lua_pushboolean(L, pmk_isFile(filename));
	return (1);
}


int pmk_os_matchDone(lua_State* L)
{
	Matcher* matcher = (Matcher*)lua_touserdata(L, 1);
	pmk_matchDone(matcher);
	return (0);
}


int pmk_os_matchName(lua_State* L)
{
	char buffer[PATH_MAX];

	Matcher* matcher = (Matcher*)lua_touserdata(L, 1);
	pmk_matchName(matcher, buffer, PATH_MAX);
	lua_pushstring(L, buffer);
	return (1);
}


int pmk_os_matchNext(lua_State* L)
{
	Matcher* matcher = (Matcher*)lua_touserdata(L, 1);
	lua_pushboolean(L, pmk_matchNext(matcher));
	return (1);
}


int pmk_os_matchStart(lua_State* L)
{
	const char* directory = luaL_checkstring(L, 1);
	const char* mask = luaL_checkstring(L, 2);
	Matcher* matcher = pmk_matchStart(directory, mask);

	if (matcher == NULL) {
		lua_pushstring(L, "unable to encode mask");
		lua_error(L);
		return (0);
	}

	lua_pushlightuserdata(L, matcher);
	return (1);
}


int pmk_os_mkdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	if (pmk_mkdir(path) != OKAY) {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to create directory '%s'", path);
		return (2);
	}

	lua_pushboolean(L, TRUE);
	return (1);
}


int pmk_os_touch(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	if (pmk_touchFile(path) != OKAY) {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to touch '%s'", path);
	}

	lua_pushboolean(L, TRUE);
	return (1);
}


int pmk_os_uuid(lua_State* L)
{
	char uuid[38];

	const char* value = luaL_optstring(L, 1, NULL);
	if (pmk_uuid(uuid, value)) {
		lua_pushstring(L, uuid);
		return (1);
	} else {
		lua_pushnil(L);
		lua_pushstring(L, "failed to create UUID");
		return (2);
	}
}
