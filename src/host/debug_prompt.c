/**
 * \file   debug_prompt.c
 * \brief  Display a prompt and enter interactive REPL mode.
 * \author Copyright (c) 2014 Jess Perkins and the Premake project
 */

#include "premake.h"

/* Build on the REPL built into Lua already */
#define main lua_main
#include "lua.c"


/* Based on dotty() in lua.c */
int debug_prompt(lua_State* L)
{
	int status;

	const char* oldProgName = progname;
	progname = NULL;

	while ((status = loadline(L)) != -1) {
		if (status == 0) {
			status = docall(L, 0, 0);
		}

		report(L, status);

		if (status == 0 && lua_gettop(L) > 0) {  /* any result to print? */
			lua_getglobal(L, "print");
			lua_insert(L, 1);
			if (lua_pcall(L, lua_gettop(L) - 1, 0, 0) != 0) {
				l_message(progname, lua_pushfstring(L,
					"error calling " LUA_QL("print") " (%s)",
					lua_tostring(L, -1))
				);
			}
		}
	}

	lua_settop(L, 0);  /* clear stack */
	fputs("\n", stdout);
	fflush(stdout);
	progname = oldProgName;
	return 0;
}

