/**
 * Implementations for Premake's `xml.*` functions.
 */

#include "../premake_internal.h"


int pmk_xml_escape(lua_State* L)
{
	char buffer[PATH_MAX];
	const char* value = luaL_optstring(L, 1, "");
	pmk_escapeXml(buffer, value);
	lua_pushstring(L, buffer);
	return (1);
}
