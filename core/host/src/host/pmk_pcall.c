#include "../premake_internal.h"

static int onRuntimeError(lua_State* L);


/**
 * A replacement for Lua's `pcall()` which returns extended error information.
 */
int pmk_pcall(lua_State* L, int nargs, int nresults)
{
	lua_pushcfunction(L, onRuntimeError);

	/* insert error handler before call parameters */
	int errorHandlerIndex = (lua_gettop(L) - nargs - 1);
	lua_insert(L, errorHandlerIndex);

	/* make the call */
	int result = lua_pcall(L, nargs, nresults, errorHandlerIndex);

	lua_remove(L, errorHandlerIndex);
	return (result);
}


static int onRuntimeError(lua_State* L)
{
	/* get the error message */
	const char* message = lua_tostring(L, -1);

	/* retrieve the stack trace via a call to debug.traceback() */
	lua_getglobal(L, "debug");
	lua_getfield(L, -1, "traceback");
	lua_remove(L, -2);      /* remove debug table */
	lua_insert(L, -2);      /* insert traceback() function before message */
	lua_pushinteger(L, 3);  /* push the starting level for traceback() */
	lua_call(L, 2, 1);
	const char* traceback = lua_tostring(L, -1);
	lua_pop(L, 1);

	/* put message and traceback in a table */
	lua_newtable(L);

	lua_pushstring(L, "message");
	lua_pushstring(L, message);
	lua_settable(L, -3);

	lua_pushstring(L, "traceback");
	lua_pushstring(L, traceback);
	lua_settable(L, -3);

	return (1);
}
