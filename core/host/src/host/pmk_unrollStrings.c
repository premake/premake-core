#include "../premake_internal.h"


/**
 * Maps one or more string values to a new set of values.
 *
 * @param L
 *    The Lua state.
 * @param valueIndex
 *    The Lua stack index of the value(s) to be mapped. If the value at this index is a
 *    table, each array value of the table will be iterated and mapped.
 * @param param
 *    A string parameter to send to the mapping function; may be `NULL`.
 * @param mappingFunction
 *    A function to be called for each value to be mapped; receives a buffer to contain
 *    the mapped value, the value to be mapped, and `param` as parameters. The function
 *    should return `buffer` if the value is to be added to the result, or `NULL` otherwise.
 * @returns
 *    If the source value is a table, returns a new table containing the mapped values.
 *    If the source value is a string, returns the mapped string value.
 */
int pmk_mapStrings(lua_State* L, int valueIndex, const char* param, const char* (*mappingFunction)(char*, const char*, const char*))
{
	char buffer[PATH_MAX];

	int t = lua_type(L, valueIndex);
	if (t == LUA_TTABLE) {
		lua_newtable(L);

		int n = lua_rawlen(L, valueIndex);
		for (int i = 1; i <= n; ++i) {
			lua_rawgeti(L, valueIndex, i);

			const char* value = lua_tostring(L, -1);
			if (value != NULL) {
				// call the handler with args in the same order as provided in script
				if (valueIndex == 1)
					value = mappingFunction(buffer, value, param);
				else
					value = mappingFunction(buffer, param, value);
			}

			lua_pushstring(L, value);
			lua_rawseti(L, -3, i);

			lua_pop(L, 1);
		}
	}
	else {
		const char* value = lua_tostring(L, valueIndex);
		if (value != NULL) {
			// call the handler with args in the same order as provided in script
			if (valueIndex == 1)
				value = mappingFunction(buffer, value, param);
			else
				value = mappingFunction(buffer, param, value);
		}

		lua_pushstring(L, value);
	}

	return (1);
}


/**
 * Test a "haystack" against one or more "needle" values.
 *
 * @param L
 *    The Lua state. The haystack should be the first argument on the stack, followed by
 *    one or more needles. If the needles are stored in a table, that table is iterated
 *    and each value tested in turn, stopping at the first positive match.
 * @param testFunction
 *    A function to be called for each value provided; receives the haystack and a
 *    needle value as parameters.
 * @returns
 *    If a positive match is found, returns the corresponding needle. If not match is
 *    found, returns `nil`.
 */
int pmk_testStrings(lua_State* L, int (*testFunction)(const char*, const char*))
{
	const char* haystack = luaL_optstring(L, 1, NULL);
	if (haystack == NULL)
		return (0);

	int t = lua_type(L, 2);
	if (t == LUA_TTABLE) {
		int n = lua_rawlen(L, 2);
		for (int i = 1; i <= n; ++i) {
			lua_rawgeti(L, 2, i);
			const char* needle = lua_tostring(L, -1);
			if (needle != NULL && testFunction(haystack, needle))
				return (1);
			lua_pop(L, 1);
		}
	}
	else {
		// Handle one or more (variadic) parameters
		int n = lua_gettop(L);
		for (int i = 2; i <= n; ++i) {
			const char* needle = lua_tostring(L, i);
			if (needle != NULL && testFunction(haystack, needle)) {
				lua_pushvalue(L, i);
				return (1);
			}
		}
	}

	return (0);
}
