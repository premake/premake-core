-- SPDX-License-Identifier: MIT
-- Copyright (c) 2024 Scott Lembcke and Howling Moon Software

local template = [==[
// SPDX-License-Identifier: MIT
// Copyright (c) 2024 Scott Lembcke and Howling Moon Software

/*
	Using debugger.lua from C code is pretty straightforward.
	Basically you just need to call one of the setup functions to make the debugger available.
	Then you can reference the debugger in your Lua code as normal.
	If you want to wrap the lua code from your C entrypoints, you can use
	dbg_pcall() or dbg_dofile() instead.
	
	That's it!!
	
	#include <stdio.h>
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
	
	#define DEBUGGER_LUA_IMPLEMENTATION
	#include "debugger_lua.h"
	
	int main(int argc, char **argv){
		lua_State *lua = luaL_newstate();
		luaL_openlibs(lua);
		
		// This defines a module named 'debugger' which is assigned to a global named 'dbg'.
		// If you want to change these values or redirect the I/O, then use dbg_setup() instead.
		dbg_setup_default(lua);
		
		luaL_loadstring(lua,
			"local num = 1\n"
			"local str = 'one'\n"
			"local res = num + str\n"
		);
		
		// Call into the lua code, and catch any unhandled errors in the debugger.
		if(dbg_pcall(lua, 0, 0, 0)){
			fprintf(stderr, "Lua Error: %s\n", lua_tostring(lua, -1));
		}
	}
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef struct lua_State lua_State;
typedef int (*lua_CFunction)(lua_State *L);

// This function must be called before calling dbg_pcall() to set up the debugger module.
// 'name' must be the name of the module to register the debugger as. (to use with require 'module')
// 'globalName' can either be NULL or a global variable name to assign the debugger to. (I use "dbg")
// 'readFunc' is a lua_CFunction that returns a line of input when called. Pass NULL if you want to read from stdin.
// 'writeFunc' is a lua_CFunction that takes a single string as an argument. Pass NULL if you want to write to stdout.
void dbg_setup(lua_State *lua, const char *name, const char *globalName, lua_CFunction readFunc, lua_CFunction writeFunc);

// Same as 'dbg_setup(lua, "debugger", "dbg", NULL, NULL)'
void dbg_setup_default(lua_State *lua);

// Drop in replacement for lua_pcall() that attaches the debugger on an error if 'msgh' is 0.
int dbg_pcall(lua_State *lua, int nargs, int nresults, int msgh);

// Drop in replacement for luaL_dofile()
#define dbg_dofile(lua, filename) (luaL_loadfile(lua, filename) || dbg_pcall(lua, 0, LUA_MULTRET, 0))

#ifdef DEBUGGER_LUA_IMPLEMENTATION

#include <stdbool.h>
#include <assert.h>
#include <string.h>

static const char DEBUGGER_SRC[] = {{=lua_src}};

int luaopen_debugger(lua_State *lua){
	if(
		luaL_loadbufferx(lua, DEBUGGER_SRC, sizeof(DEBUGGER_SRC) - 1, "<debugger.lua>", NULL) ||
		lua_pcall(lua, 0, LUA_MULTRET, 0)
	) lua_error(lua);
	
	// Or you could load it from disk:
	// if(luaL_dofile(lua, "debugger.lua")) lua_error(lua);
	
	return 1;
}

static const char *MODULE_NAME = "DEBUGGER_LUA_MODULE";
static const char *MSGH = "DEBUGGER_LUA_MSGH";

void dbg_setup(lua_State *lua, const char *name, const char *globalName, lua_CFunction readFunc, lua_CFunction writeFunc){
	// Check that the module name was not already defined.
	lua_getfield(lua, LUA_REGISTRYINDEX, MODULE_NAME);
	assert(lua_isnil(lua, -1) || strcmp(name, luaL_checkstring(lua, -1)));
	lua_pop(lua, 1);
	
	// Push the module name into the registry.
	lua_pushstring(lua, name);
	lua_setfield(lua, LUA_REGISTRYINDEX, MODULE_NAME);
	
	// Preload the module
	luaL_requiref(lua, name, luaopen_debugger, false);
	
	// Insert the msgh function into the registry.
	lua_getfield(lua, -1, "msgh");
	lua_setfield(lua, LUA_REGISTRYINDEX, MSGH);
	
	if(readFunc){
		lua_pushcfunction(lua, readFunc);
		lua_setfield(lua, -2, "read");
	}
	
	if(writeFunc){
		lua_pushcfunction(lua, writeFunc);
		lua_setfield(lua, -2, "write");
	}
	
	if(globalName){
		lua_setglobal(lua, globalName);
	} else {
		lua_pop(lua, 1);
	}
}

void dbg_setup_default(lua_State *lua){
	dbg_setup(lua, "debugger", "dbg", NULL, NULL);
}

int dbg_pcall(lua_State *lua, int nargs, int nresults, int msgh){
	// Call regular lua_pcall() if a message handler is provided.
	if(msgh) return lua_pcall(lua, nargs, nresults, msgh);
	
	// Grab the msgh function out of the registry.
	lua_getfield(lua, LUA_REGISTRYINDEX, MSGH);
	if(lua_isnil(lua, -1)){
		luaL_error(lua, "Tried to call dbg_call() before calling dbg_setup().");
	}
	
	// Move the error handler just below the function.
	msgh = lua_gettop(lua) - (1 + nargs);
	lua_insert(lua, msgh);
	
	// Call the function.
	int err = lua_pcall(lua, nargs, nresults, msgh);
	
	// Remove the debug handler.
	lua_remove(lua, msgh);
	
	return err;
}

#endif

#ifdef __cplusplus
}
#endif
]==]

local append, join, format = table.insert, table.concat, string.format

-- return a list and a function that appends its arguments into the list
local function appender(lines)
	return lines, function(...) append(lines, join{...}) end
end

local elua = {}

function elua.generate(template)
	-- push an initial line to recieve args from the wrapping closure
	local cursor, fragments, append = 1, appender{"local __elua, _ENV = ...\n"}
	
	while true do
		-- find a code block
		local i0, i1, m1, m2 = template:find("{{(=?)(.-)}}", cursor)
		
		if i0 == nil then
			-- if no code block, append remainder and join
			append("__elua", format("%q", template:sub(cursor, #template)))
			return join(fragments, "; ")
		elseif cursor ~= i0 then
			-- if there is text to output, output it
			append("__elua", format("%q", template:sub(cursor, i0 - 1)))
		end
		
		if m1 == "=" then
			-- append expression
			append("__elua(", m2, ")")
		else
			-- append code
			append(m2)
		end
		
		cursor = i1 + 1
	end
end

function elua.compile(template, name)
	local template_code = elua.generate(template)
	
	-- compile the template's lua code
	local chunk, err = load(template_code, name or "COMPILED TEMPLATE", "t")
	if err then return nil, err end
	
	-- wrap chunk in closure to collect and join it's output fragments
	return function(env)
		local fragments, append = appender{}
		chunk(append, env)
		return join(fragments)
	end
end

local input_filename = arg[1] or "debugger.lua"
local output_filename = arg[2] or "debugger_lua.h"

local lua_src = io.open(input_filename):read("a")

-- Fix the weird escape characters
lua_src = string.format("%q", lua_src)
lua_src = string.gsub(lua_src, "\\\n", "\\n")
lua_src = string.gsub(lua_src, "\\9", "\\t")


local output = elua.compile(template){lua_src = lua_src}
io.open(output_filename, "w"):write(output)
