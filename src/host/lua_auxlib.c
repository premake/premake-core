/**
 * \file   lua_auxlib.c
 * \brief  Modifications and extensions to Lua's library functions.
 * \author Copyright (c) 2014-2017 Jess Perkins and the Premake project
 */

#include "premake.h"
#include <assert.h>
#include <string.h>


static int chunk_wrapper(lua_State* L);



/**
 * Extend the default implementation of luaL_loadfile() to call my chunk
 * wrapper, above, before executing any scripts loaded from a file.
 */
int premake_luaL_loadfilex (lua_State* L, const char* filename, const char* mode)
{
	const char* script_dir;
	const char* test_name;

	/* this function is usually called with from 1 to 3 arguments on the stack,
	 * the filename, the mode and an environment table */

	/* however, in the case of require, we end up being called from searcher_Lua,
	   which sets up extra values on the stack */
	int bottom = lua_gettop(L);
	int is_require = bottom >= 4;

  	int env = (!is_require && !lua_isnone(L, 3)) ? 1 : 0;  /* 1 if there is an env or 0 if no 'env' */
	int z = !OKAY;

	/* If filename starts with "$/" then we want to load the version that
	 * was embedded into the executable and skip the local file system */
	if (filename[0] == '$') {
		z = premake_load_embedded_script(L, filename + 2); /* Skip over leading "$/" */
		if (z != OKAY) {
			return z;
		}
	}

	/* If the currently running script was embedded, try to load this file
	 * as it if were embedded too. */
	if (z != OKAY) {
		lua_getglobal(L, "_SCRIPT_DIR");
		script_dir = lua_tostring(L, -1);
		int script_dir_index = lua_gettop(L);

		if (script_dir && script_dir[0] == '$') {
			/* Call `path.getabsolute(filename, _SCRIPT_DIR)` to resolve any
			 * "../" sequences in the filename */
			lua_pushcfunction(L, path_getabsolute);
			lua_pushstring(L, filename);
			lua_pushvalue(L, -3);
			lua_call(L, 2, 1);
			test_name = lua_tostring(L, -1);
			int test_name_index = lua_gettop(L);

			/* if successful, filename and chunk will be on top of stack */
			z = premake_load_embedded_script(L, test_name + 2); /* Skip over leading "$/" */

			/* remove test_name */
			lua_remove(L, test_name_index);
		}

		/* remove _SCRIPT_DIR */
		lua_remove(L, script_dir_index);
	}

	/* Try to locate the script on the filesystem */
	if (z != OKAY) {
		lua_pushcfunction(L, os_locate);
		lua_pushstring(L, filename);
		lua_call(L, 1, 1);

		test_name = lua_tostring(L, -1);

		if (test_name) {
			z = luaL_loadfilex(L, test_name, mode);
		}

		/* If the file exists but errors, pass that through */
		if (test_name && z != OKAY && z != LUA_ERRFILE) {
			return z;
		}

		/* If the file didn't exist, remove the result and the test
		 * name from the stack before checking embedded scripts */
		if (z != OKAY) {
			lua_pop(L, 1);
		}
	}

	/* Try to load from embedded scripts */
	if (z != OKAY) {
		z = premake_load_embedded_script(L, filename);
	}

	/* Either way I should have ended up with the file name followed by the
	 * script chunk on the stack. Turn these into a closure that will call my
	 * wrapper below when the loaded script needs to be executed. */

	assert(lua_gettop(L) == bottom + 2);

	if (z == OKAY) {
		/* if we are called with an env, then our caller, luaB_loadfile, will
		 * call load_aux, which sets up our env as the first up value via
		 * lua_setupvalue, which would overwrite the one we are setting up here.
		 * workaround this by pushing a nil value as our first up value */
		if (env) {
			lua_pushnil(L);
			lua_insert(L, -3);
		}
		lua_pushcclosure(L, chunk_wrapper, 2 + (env ? 1 : 0));
	}
	else if (z == LUA_ERRFILE) {
		lua_pushfstring(L, "cannot open %s: No such file or directory", filename);
	}

	return z;
}



/**
 * Execute a chunk of code previously loaded by my customized version of
 * luaL_loadfile(), below. Sets the _SCRIPT global variable to the absolute
 * path of the loaded chunk, and makes its enclosing directory current so
 * that relative path references to other files or scripts can be used.
 */

static int chunk_wrapper(lua_State* L)
{
	char cwd[PATH_MAX];
	const char* filename;
	char* ptr;
	int i, args;
	int upvalue_offset;

	args = lua_gettop(L);

	/* if the first up value is a table, then we have an env upvalue
	 * and should take that into account by offsetting the rest of the up values */
	upvalue_offset = (lua_type(L, lua_upvalueindex(1)) == LUA_TTABLE) ? 1 : 0;

	/* Remember the current _SCRIPT and working directory so I can
	 * restore them after this new chunk has been run. */

	do_getcwd(cwd, PATH_MAX);
	lua_getglobal(L, "_SCRIPT");
	lua_getglobal(L, "_SCRIPT_DIR");

	/* Set the new _SCRIPT variable */

	lua_pushvalue(L, lua_upvalueindex(1 + upvalue_offset));
	lua_setglobal(L, "_SCRIPT");

	/* And the new _SCRIPT_DIR variable (const cheating) */

	filename = lua_tostring(L, lua_upvalueindex(1 + upvalue_offset));
	ptr = strrchr(filename, '/');
	if (ptr) *ptr = '\0';
	lua_pushlstring(L, filename, strlen(filename));
	lua_setglobal(L, "_SCRIPT_DIR");

	/* And make that the CWD (and fix the const cheat) */

	if (filename[0] != '$') {
		do_chdir(L, filename);
	}
	if (ptr) *ptr = '/';

	/* Move the function's arguments to the top of the stack and
	 * execute the function created by luaL_loadfile() */

	lua_pushvalue(L, lua_upvalueindex(2 + upvalue_offset));

	/* forward the env table to the closure as 1st upvalue */
	if (upvalue_offset) {
		lua_pushvalue(L, -1);
	 	lua_pushvalue(L, lua_upvalueindex(1));
		lua_setupvalue(L, -2, 1);
	}

	for (i = 1; i <= args; ++i) {
		lua_pushvalue(L, i);
	}

	lua_call(L, args, LUA_MULTRET);

	/* Finally, restore the previous _SCRIPT variable and working directory
	 * before returning control to the previously executing script. */

	do_chdir(L, cwd);
	lua_pushvalue(L, args + 1);
	lua_setglobal(L, "_SCRIPT");
	lua_pushvalue(L, args + 2);
	lua_setglobal(L, "_SCRIPT_DIR");

	return lua_gettop(L) - args - 2;
}


/**
 * Copy of load_aux from lbaselib.c in Lua source
 */
static int load_aux(lua_State *L, int status, int envidx) {
	if (status == LUA_OK) {
		if (envidx != 0) {  /* 'env' parameter? */
			lua_pushvalue(L, envidx);  /* environment for loaded function */
			if (!lua_setupvalue(L, -2, 1))  /* set it as 1st upvalue */
				lua_pop(L, 1);  /* remove 'env' if not used by previous call */
		}
		return 1;
	}
	else {  /* error (message is on top of the stack) */
		lua_pushnil(L);
		lua_insert(L, -2);  /* put before error message */
		return 2;  /* return nil plus error message */
	}
}


/**
 * Extend the default implementation of luaB_loadfile() to call our
 * luaL_loadfilex implementation.
 */
int premake_luaB_loadfile(lua_State *L)
{
	const char *fname = luaL_optstring(L, 1, NULL);
	const char *mode = luaL_optstring(L, 2, NULL);
	int env = (!lua_isnone(L, 3) ? 3 : 0);  /* 'env' index or 0 if no 'env' */
	int status = premake_luaL_loadfilex(L, fname, mode);
	return load_aux(L, status, env);
}


/**
 * Copy of dofilecont from lbaselib.c in Lua source
 */
static int dofilecont(lua_State *L, int d1, lua_KContext d2) {
	(void)d1;  (void)d2;  /* only to match 'lua_Kfunction' prototype */
	return lua_gettop(L) - 1;
}


/**
 * Extend the default implementation of luaB_dofile() to call our
 * luaL_loadfilex implementation.
 */
int premake_luaB_dofile(lua_State *L)
{
	const char *fname = luaL_optstring(L, 1, NULL);
	lua_settop(L, 1);
	if (premake_luaL_loadfile(L, fname) != LUA_OK)
		return lua_error(L);
	lua_callk(L, 0, LUA_MULTRET, 0, dofilecont);
	return dofilecont(L, 0, 0);
}


 /**
  * Copy of readable from loadlib.c in Lua source
  */
static int readable(const char *filename) {
	FILE *f = fopen(filename, "r");  /* try to open file */
	if (f == NULL) return 0;  /* open failed */
	fclose(f);
	return 1;
}


/**
 * Copy of pushnexttemplate from loadlib.c in Lua source
 */
static const char *pushnexttemplate(lua_State *L, const char *path) {
	const char *l;
	while (*path == *LUA_PATH_SEP) path++;  /* skip separators */
	if (*path == '\0') return NULL;  /* no more templates */
	l = strchr(path, *LUA_PATH_SEP);  /* find next separator */
	if (l == NULL) l = path + strlen(path);
	lua_pushlstring(L, path, l - path);  /* template */
	return l;
}


/**
 * Copy of searchpath from loadlib.c in Lua source
 */
static const char *searchpath(lua_State *L, const char *name,
	const char *path,
	const char *sep,
	const char *dirsep) {
	luaL_Buffer msg;  /* to build error message */
	luaL_buffinit(L, &msg);
	if (*sep != '\0')  /* non-empty separator? */
		name = luaL_gsub(L, name, sep, dirsep);  /* replace it by 'dirsep' */
	while ((path = pushnexttemplate(L, path)) != NULL) {
		const char *filename = luaL_gsub(L, lua_tostring(L, -1),
			LUA_PATH_MARK, name);
		lua_remove(L, -2);  /* remove path template */
		if (readable(filename))  /* does file exist and is readable? */
			return filename;  /* return that file name */
		lua_pushfstring(L, "\n\tno file '%s'", filename);
		lua_remove(L, -2);  /* remove file name */
		luaL_addvalue(&msg);  /* concatenate error msg. entry */
	}
	luaL_pushresult(&msg);  /* create error message */
	return NULL;  /* not found */
}


/**
 * Copy of findfile from loadlib.c in Lua source
 */
static const char *findfile(lua_State *L, const char *name,
	const char *pname,
	const char *dirsep) {
	const char *path;
	lua_getfield(L, lua_upvalueindex(1), pname);
	path = lua_tostring(L, -1);
	if (path == NULL)
		luaL_error(L, "'package.%s' must be a string", pname);
	return searchpath(L, name, path, ".", dirsep);
}


/**
 * Copy of checkload from loadlib.c in Lua source
 */
static int checkload(lua_State *L, int stat, const char *filename) {
	if (stat) {  /* module loaded successfully? */
		lua_pushstring(L, filename);  /* will be 2nd argument to module */
		return 2;  /* return open function and file name */
	}
	else
		return luaL_error(L, "error loading module '%s' from file '%s':\n\t%s",
			lua_tostring(L, 1), filename, lua_tostring(L, -1));
}


/**
 * Extend the default implementation of requires 'searcher_Lua' function
 * to use our luaL_loadfilex implementation.
 */
int premake_searcher_Lua(lua_State *L) {
	const char *filename;
	const char *name = luaL_checkstring(L, 1);
	filename = findfile(L, name, "path", LUA_DIRSEP);
	if (filename == NULL) return 1;  /* module not found in this path */
	return checkload(L, (premake_luaL_loadfile(L, filename) == LUA_OK), filename);
}
