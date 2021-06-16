/**
 * Implementations for Premake's `buffer.*` functions.
 */

#include "../premake_internal.h"


int pmk_buffer_new(lua_State* L)
{
	pmk_Buffer* b = pmk_bufferInit();
	lua_pushlightuserdata(L, b);
	return (1);
}


int pmk_buffer_write(lua_State* L)
{
	pmk_Buffer* b = (pmk_Buffer*)lua_touserdata(L, 1);

	size_t len;
	const char* s = luaL_checklstring(L, 2, &len);

	pmk_bufferPuts(b, s, len);
	return (0);
}


int pmk_buffer_writeLine(lua_State* L)
{
	pmk_Buffer* b = (pmk_Buffer*)lua_touserdata(L, 1);

	size_t len;
	const char* s = luaL_optlstring(L, 2, NULL, &len);

	if (s != NULL) {
		pmk_bufferPuts(b, s, len);
	}

	pmk_bufferPuts(b, "\r\n", 2);
	return (0);
}


int pmk_buffer_close(lua_State* L)
{
	pmk_buffer_toString(L);

	pmk_Buffer* b = (pmk_Buffer*)lua_touserdata(L, 1);
	pmk_bufferClose(b);
	return (1);
}


int pmk_buffer_toString(lua_State* L)
{
	pmk_Buffer* b = (pmk_Buffer*)lua_touserdata(L, 1);

	size_t len = pmk_bufferLen(b);
	const char* contents = pmk_bufferContents(b);

	if (len > 0) {
		/* trim EOL from end of buffer */
		if (contents[len - 1] == '\n')
			--len;
		if (contents[len - 1] == '\r')
			--len;
	}

	if (len > 0)
		lua_pushlstring(L, contents, len);
	else
		lua_pushstring(L, "");

	return (1);
}
