/**
 * Implementations for Premake's `terminal.*` functions.
 */

#include "../premake_internal.h"


int pmk_terminal_textColor(lua_State* L)
{
	if (lua_gettop(L) > 0) {
		int color = (int)luaL_checkinteger(L, 1);
		pmk_setTextColor(color);
	}

	int color = pmk_getTextColor();
	lua_pushinteger(L, color);
	return (1);
}
