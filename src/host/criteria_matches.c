/**
 * \file   criteria_matches.c
 * \brief  Determine if this criteria is met by the provided filter terms.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


/*
 * return value:match(pattern) == value
 */
static int match(lua_State* L, const char* value, const char* pattern, int wildcard)
{
	if (wildcard) {
		const char* result;
		int matched = 0;

		int top = lua_gettop(L);

		lua_pushvalue(L, 4);
		lua_pushstring(L, value);
		lua_pushstring(L, pattern);
		lua_call(L, 2, 1);

		if (lua_isstring(L, -1)) {
			result = lua_tostring(L, -1);
			matched = (strcmp(value, result) == 0);
		}

		lua_settop(L, top);
		return matched;
	}
	else {
		return (strcmp(value, pattern) == 0);
	}
}


/*
 * Compares the value on the top of the stack to the provided
 * part, which is a Lua pattern string.
 */
static int testValue(lua_State* L, const char* part, const int wildcard)
{
	const char* value;
	size_t i, n;
	int result;

	/*
		if type(value) == "table" then
			for i = 1, #value do
				if testValue(value[i], part) then
					return true
				end
			end
		else
			if value and value:match(part) == value then
				return true;
			end
		end
	*/

	if (lua_istable(L, -1)) {
		n = lua_objlen(L, -1);
		for (i = 1; i <= n; ++i) {
			lua_rawgeti(L, -1, i);
			result = testValue(L, part, wildcard);
			lua_pop(L, 1);
			if (result) {
				return 1;
			}
		}
		return 0;
	}

	value = lua_tostring(L, -1);
	if (value && match(L, value, part, wildcard)) {
		return 1;
	}

	return 0;
}


/*
 * The context is a set of key-value pairs, something like:
 *   {
 *     action = "vs2010",
 *     configurations = "Debug",
 *     system = "windows",
 *     files = "/absolute/path/to/hello.cpp",
 *     -- and so on...
 *   }
 */
static int testContext(lua_State* L, const char* prefix, const char* part,
                       const int assertion, const int wildcard,
                       const char* filename, int* fileMatched)
{
	/*
		if prefix then
			local result = testValue(context[prefix], part, wildcard)
			if result == assertion and prefix == "files" then
				filematched = true
			end
			if result then
				return assertion
			end
		else
			if filename and assertion and filename:match(part) == filename then
				filematched = true
				return assertion
			end

			for prefix, value in pairs(context) do
				if testValue(value, part, wildcard) then
					return assertion
				end
			end
		end
	*/

	int result;
	if (prefix) {
		lua_getfield(L, 2, prefix);
		result = testValue(L, part, wildcard);
		lua_pop(L, 1);
		if (result == assertion && strcmp(prefix, "files") == 0) {
			(*fileMatched) = 1;
		}
		if (result) {
			return assertion;
		}
	}
	else {
		if (filename && assertion && match(L, filename, part, wildcard)) {
			(*fileMatched) = 1;
			return assertion;
		}

		lua_pushnil(L);
		while (lua_next(L, 2)) {
			if (testValue(L, part, wildcard)) {
				lua_pop(L, 2);
				return assertion;
			}
			lua_pop(L, 1);
		}
	}

	return (!assertion);
}



/*
 * Patterns are represented as an array of string values.
 *   "windows" = { "windows" }
 *   "not windows" = { "not", "windows" }
 *   "windows or linux" = { "windows", "linux" }
 *
 * If the patterns is targeted at a specific prefix, that is stored
 * as a keyed value.
 *
 *   "files:**.c"  = { prefix="files", "**.c" }
 */
static int testPattern(lua_State* L, const char* filename, int* fileMatched)
{
	const char* prefix;
	const char* part;
	size_t i, n;
	int assertion = 1;
	int wildcard = 0;
	int result = 0;

	/* prefix = pattern.prefix */
	lua_getfield(L, -1, "prefix");
	prefix = lua_tostring(L, -1);

	/*
		for i = 1, #pattern do
			part = pattern[i]
			if part == "not" then
				assertion = false
			else
				if testContext(pattern.prefix, part, assertion) then
					result = true
					break
				end
				assertion = true
			end
		end
	*/

	n = lua_objlen(L, -2);
	for (i = 1; i <= n; ++i) {
		lua_rawgeti(L, -2, i);
		part = lua_tostring(L, -1);

		if (strcmp(part, "not") == 0) {
			assertion = 0;
		}
		else if (part[0] == '%' && part[1] == '%') {
			wildcard = 1;
		}
		else {
			if (testContext(L, prefix, part, assertion, wildcard, filename, fileMatched)) {
				lua_pop(L, 1);
				result = 1;
				break;
			}
			assertion = 1;
			wildcard = 0;
		}

		lua_pop(L, 1);
	}

	lua_pop(L, 1);
	return result;
}



int criteria_matches(lua_State* L)
{
	/* stack [1] = criteria */
	/* stack [2] = context */

	const char* filename;
	int top = lua_gettop(L);
	int matched = 1;
	int fileMatched = 0;

	/*
		Cache string.match for a quicker lookup in match() above
		stack[3] = string
		stack[4] = string.match
	*/

	lua_getglobal(L, "string");
	lua_getfield(L, -1, "match");

	/* filename = context.files */

	lua_getfield(L, 2, "files");
	filename = lua_tostring(L, -1);

	/*
		for i, pattern in pairs(criteria.patterns) do
			if not testPattern(pattern) then
				matched = false
				break
			end
		end
	*/

	lua_getfield(L, 1, "patterns");
	lua_pushnil(L);
	while (lua_next(L, -2)) {
		if (!testPattern(L, filename, &fileMatched)) {
			matched = 0;
			break;
		}
		lua_pop(L, 1);
	}

	/*
		if matched and filename and not filematched then
			matched = false
		end
		return matched
	*/

	if (matched && filename && !fileMatched) {
		matched = 0;
	}

	lua_settop(L, top);
	lua_pushboolean(L, matched);
	return 1;
}
