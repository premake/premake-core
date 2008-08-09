/**
 * \file   luastate.h
 * \brief  An accessor for a Lua runtime state object.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 *
 * \defgroup luastate Lua State
 * \ingroup  base
 *
 * A wrapper around a global Lua state object, allowing the state to be
 * shared between the main scripting engine object and the cstr_matches_pattern()
 * function (which is in turn used by the project object).
 *
 * @{
 */
#if !defined(PREMAKE_LUASTATE_H)
#define PREMAKE_LUASTATE_H
 
#define lua_c
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


lua_State*  luastate_create(void);
void        luastate_destroy(lua_State* L);
lua_State*  luastate_get_current(void);


#endif
/** @} */

