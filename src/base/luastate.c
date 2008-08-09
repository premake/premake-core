/**
 * \file   luastate.c
 * \brief  An accessor for a Lua runtime state object.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "luastate.h"

static lua_State* Current = NULL;


/**
 * Create a new Lua state object and set the current global state.
 */
lua_State* luastate_create(void)
{
	Current = lua_open();
	luaL_openlibs(Current);
	return Current;
}


/**
 * Destroy a Lua state object and clear the current global state.
 */
void luastate_destroy(lua_State* L)
{
	assert(L);
	lua_close(L);
	if (Current == L) Current = NULL;
}


/**
 * Return the current global Lua state, or NULL if there is no currently active state.
 */
lua_State* luastate_get_current(void)
{
	return Current;
}



