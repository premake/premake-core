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

static const char DEBUGGER_SRC[] = "-- SPDX-License-Identifier: MIT\n-- Copyright (c) 2024 Scott Lembcke and Howling Moon Software\n\nlocal dbg\n\n-- Use ANSI color codes in the prompt by default.\nlocal COLOR_GRAY = \"\"\nlocal COLOR_RED = \"\"\nlocal COLOR_BLUE = \"\"\nlocal COLOR_YELLOW = \"\"\nlocal COLOR_RESET = \"\"\nlocal GREEN_CARET = \" => \"\n\nlocal function pretty(obj, max_depth)\n\tif max_depth == nil then max_depth = dbg.pretty_depth end\n\t\n\t-- Returns true if a table has a __tostring metamethod.\n\tlocal function coerceable(tbl)\n\t\tlocal meta = getmetatable(tbl)\n\t\treturn (meta and meta.__tostring)\n\tend\n\t\n\tlocal function recurse(obj, depth)\n\t\tif type(obj) == \"string\" then\n\t\t\t-- Dump the string so that escape sequences are printed.\n\t\t\treturn string.format(\"%q\", obj)\n\t\telseif type(obj) == \"table\" and depth < max_depth and not coerceable(obj) then\n\t\t\tlocal str = \"{\"\n\t\t\t\n\t\t\tfor k, v in pairs(obj) do\n\t\t\t\tlocal pair = pretty(k, 0)..\" = \"..recurse(v, depth + 1)\n\t\t\t\tstr = str..(str == \"{\" and pair or \", \"..pair)\n\t\t\tend\n\t\t\t\n\t\t\treturn str..\"}\"\n\t\telse\n\t\t\t-- tostring() can fail if there is an error in a __tostring metamethod.\n\t\t\tlocal success, value = pcall(function() return tostring(obj) end)\n\t\t\treturn (success and value or \"<!!error in __tostring metamethod!!>\")\n\t\tend\n\tend\n\t\n\treturn recurse(obj, 0)\nend\n\n-- The stack level that cmd_* functions use to access locals or info\n-- The structure of the code very carefully ensures this.\nlocal CMD_STACK_LEVEL = 6\n\n-- Location of the top of the stack outside of the debugger.\n-- Adjusted by some debugger entrypoints.\nlocal stack_top = 0\n\n-- The current stack frame index.\n-- Changed using the up/down commands\nlocal stack_inspect_offset = 0\n\n-- LuaJIT has an off by one bug when setting local variables.\nlocal LUA_JIT_SETLOCAL_WORKAROUND = 0\n\n-- Default dbg.read function\nlocal function dbg_read(prompt)\n\tdbg.write(prompt)\n\tio.flush()\n\treturn io.read()\nend\n\n-- Default dbg.write function\nlocal function dbg_write(str)\n\tio.write(str)\nend\n\nlocal function dbg_writeln(str, ...)\n\tif select(\"#\", ...) == 0 then\n\t\tdbg.write((str or \"<NULL>\")..\"\\n\")\n\telse\n\t\tdbg.write(string.format(str..\"\\n\", ...))\n\tend\nend\n\nlocal function format_loc(file, line) return COLOR_BLUE..file..COLOR_RESET..\":\"..COLOR_YELLOW..line..COLOR_RESET end\nlocal function format_stack_frame_info(info)\n\tlocal filename = info.source:match(\"@(.*)\")\n\tlocal source = filename and dbg.shorten_path(filename) or info.short_src\n\tlocal namewhat = (info.namewhat == \"\" and \"chunk at\" or info.namewhat)\n\tlocal name = (info.name and \"'\"..COLOR_BLUE..info.name..COLOR_RESET..\"'\" or format_loc(source, info.linedefined))\n\treturn format_loc(source, info.currentline)..\" in \"..namewhat..\" \"..name\nend\n\nlocal repl\n\n-- Return false for stack frames without source,\n-- which includes C frames, Lua bytecode, and `loadstring` functions\nlocal function frame_has_line(info) return info.currentline >= 0 end\n\nlocal function hook_factory(repl_threshold)\n\treturn function(offset, reason)\n\t\treturn function(event, _)\n\t\t\t-- Skip events that don't have line information.\n\t\t\tif not frame_has_line(debug.getinfo(2)) then return end\n\t\t\t\n\t\t\t-- Tail calls are specifically ignored since they also will have tail returns to balance out.\n\t\t\tif event == \"call\" then\n\t\t\t\toffset = offset + 1\n\t\t\telseif event == \"return\" and offset > repl_threshold then\n\t\t\t\toffset = offset - 1\n\t\t\telseif event == \"line\" and offset <= repl_threshold then\n\t\t\t\trepl(reason)\n\t\t\tend\n\t\tend\n\tend\nend\n\nlocal hook_step = hook_factory(1)\nlocal hook_next = hook_factory(0)\nlocal hook_finish = hook_factory(-1)\n\n-- Create a table of all the locally accessible variables.\n-- Globals are not included when running the locals command, but are when running the print command.\nlocal function local_bindings(offset, include_globals)\n\tlocal level = offset + stack_inspect_offset + CMD_STACK_LEVEL\n\tlocal func = debug.getinfo(level).func\n\tlocal bindings = {}\n\t\n\t-- Retrieve the upvalues\n\tdo local i = 1; while true do\n\t\tlocal name, value = debug.getupvalue(func, i)\n\t\tif not name then break end\n\t\tbindings[name] = value\n\t\ti = i + 1\n\tend end\n\t\n\t-- Retrieve the locals (overwriting any upvalues)\n\tdo local i = 1; while true do\n\t\tlocal name, value = debug.getlocal(level, i)\n\t\tif not name then break end\n\t\tbindings[name] = value\n\t\ti = i + 1\n\tend end\n\t\n\t-- Retrieve the varargs (works in Lua 5.2 and LuaJIT)\n\tlocal varargs = {}\n\tdo local i = 1; while true do\n\t\tlocal name, value = debug.getlocal(level, -i)\n\t\tif not name then break end\n\t\tvarargs[i] = value\n\t\ti = i + 1\n\tend end\n\tif #varargs > 0 then bindings[\"...\"] = varargs end\n\t\n\tif include_globals then\n\t\t-- In Lua 5.2, you have to get the environment table from the function's locals.\n\t\tlocal env = (_VERSION <= \"Lua 5.1\" and getfenv(func) or bindings._ENV)\n\t\treturn setmetatable(bindings, {__index = env or _G})\n\telse\n\t\treturn bindings\n\tend\nend\n\n-- Used as a __newindex metamethod to modify variables in cmd_eval().\nlocal function mutate_bindings(_, name, value)\n\tlocal FUNC_STACK_OFFSET = 3 -- Stack depth of this function.\n\tlocal level = stack_inspect_offset + FUNC_STACK_OFFSET + CMD_STACK_LEVEL\n\t\n\t-- Set a local.\n\tdo local i = 1; repeat\n\t\tlocal var = debug.getlocal(level, i)\n\t\tif name == var then\n\t\t\tdbg_writeln(COLOR_YELLOW..\"debugger.lua\"..GREEN_CARET..\"Set local variable \"..COLOR_BLUE..name..COLOR_RESET)\n\t\t\treturn debug.setlocal(level + LUA_JIT_SETLOCAL_WORKAROUND, i, value)\n\t\tend\n\t\ti = i + 1\n\tuntil var == nil end\n\t\n\t-- Set an upvalue.\n\tlocal func = debug.getinfo(level).func\n\tdo local i = 1; repeat\n\t\tlocal var = debug.getupvalue(func, i)\n\t\tif name == var then\n\t\t\tdbg_writeln(COLOR_YELLOW..\"debugger.lua\"..GREEN_CARET..\"Set upvalue \"..COLOR_BLUE..name..COLOR_RESET)\n\t\t\treturn debug.setupvalue(func, i, value)\n\t\tend\n\t\ti = i + 1\n\tuntil var == nil end\n\t\n\t-- Set a global.\n\tdbg_writeln(COLOR_YELLOW..\"debugger.lua\"..GREEN_CARET..\"Set global variable \"..COLOR_BLUE..name..COLOR_RESET)\n\t_G[name] = value\nend\n\n-- Compile an expression with the given variable bindings.\nlocal function compile_chunk(block, env)\n\tlocal source = \"debugger.lua REPL\"\n\tlocal chunk = nil\n\t\n\tif _VERSION <= \"Lua 5.1\" then\n\t\tchunk = loadstring(block, source)\n\t\tif chunk then setfenv(chunk, env) end\n\telse\n\t\t-- The Lua 5.2 way is a bit cleaner\n\t\tchunk = load(block, source, \"t\", env)\n\tend\n\t\n\tif not chunk then dbg_writeln(COLOR_RED..\"Error: Could not compile block:\\n\"..COLOR_RESET..block) end\n\treturn chunk\nend\n\nlocal SOURCE_CACHE = {}\n\nlocal function where(info, context_lines)\n\tlocal source = SOURCE_CACHE[info.source]\n\tif not source then\n\t\tsource = {}\n\t\tlocal filename = info.source:match(\"@(.*)\")\n\t\tif filename then\n\t\t\tpcall(function() for line in io.lines(filename) do table.insert(source, line) end end)\n\t\telseif info.source then\n\t\t\tfor line in info.source:gmatch(\"(.-)\\n\") do table.insert(source, line) end\n\t\tend\n\t\tSOURCE_CACHE[info.source] = source\n\tend\n\t\n\tif source and source[info.currentline] then\n\t\tfor i = info.currentline - context_lines, info.currentline + context_lines do\n\t\t\tlocal tab_or_caret = (i == info.currentline and  GREEN_CARET or \"    \")\n\t\t\tlocal line = source[i]\n\t\t\tif line then dbg_writeln(COLOR_GRAY..\"% 4d\"..tab_or_caret..\"%s\", i, line) end\n\t\tend\n\telse\n\t\tdbg_writeln(COLOR_RED..\"Error: Source not available for \"..COLOR_BLUE..info.short_src);\n\tend\n\t\n\treturn false\nend\n\n-- Wee version differences\nlocal unpack = unpack or table.unpack\nlocal pack = function(...) return {n = select(\"#\", ...), ...} end\n\nlocal function cmd_step()\n\tstack_inspect_offset = stack_top\n\treturn true, hook_step\nend\n\nlocal function cmd_next()\n\tstack_inspect_offset = stack_top\n\treturn true, hook_next\nend\n\nlocal function cmd_finish()\n\tlocal offset = stack_top - stack_inspect_offset\n\tstack_inspect_offset = stack_top\n\treturn true, offset < 0 and hook_factory(offset - 1) or hook_finish\nend\n\nlocal function cmd_print(expr)\n\tlocal env = local_bindings(1, true)\n\tlocal chunk = compile_chunk(\"return \"..expr, env)\n\tif chunk == nil then return false end\n\t\n\t-- Call the chunk and collect the results.\n\tlocal results = pack(pcall(chunk, unpack(rawget(env, \"...\") or {})))\n\t\n\t-- The first result is the pcall error.\n\tif not results[1] then\n\t\tdbg_writeln(COLOR_RED..\"Error:\"..COLOR_RESET..\" \"..results[2])\n\telse\n\t\tlocal output = \"\"\n\t\tfor i = 2, results.n do\n\t\t\toutput = output..(i ~= 2 and \", \" or \"\")..dbg.pretty(results[i])\n\t\tend\n\t\t\n\t\tif output == \"\" then output = \"<no result>\" end\n\t\tdbg_writeln(COLOR_BLUE..expr.. GREEN_CARET..output)\n\tend\n\t\n\treturn false\nend\n\nlocal function cmd_eval(code)\n\tlocal env = local_bindings(1, true)\n\tlocal mutable_env = setmetatable({}, {\n\t\t__index = env,\n\t\t__newindex = mutate_bindings,\n\t})\n\t\n\tlocal chunk = compile_chunk(code, mutable_env)\n\tif chunk == nil then return false end\n\t\n\t-- Call the chunk and collect the results.\n\tlocal success, err = pcall(chunk, unpack(rawget(env, \"...\") or {}))\n\tif not success then\n\t\tdbg_writeln(COLOR_RED..\"Error:\"..COLOR_RESET..\" \"..tostring(err))\n\tend\n\t\n\treturn false\nend\n\nlocal function cmd_down()\n\tlocal offset = stack_inspect_offset\n\tlocal info\n\t\n\trepeat -- Find the next frame with a file.\n\t\toffset = offset + 1\n\t\tinfo = debug.getinfo(offset + CMD_STACK_LEVEL)\n\tuntil not info or frame_has_line(info)\n\t\n\tif info then\n\t\tstack_inspect_offset = offset\n\t\tdbg_writeln(\"Inspecting frame: \"..format_stack_frame_info(info))\n\t\tif tonumber(dbg.auto_where) then where(info, dbg.auto_where) end\n\telse\n\t\tinfo = debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL)\n\t\tdbg_writeln(\"Already at the bottom of the stack.\")\n\tend\n\t\n\treturn false\nend\n\n"
"local function cmd_up()\n\tlocal offset = stack_inspect_offset\n\tlocal info\n\t\n\trepeat -- Find the next frame with a file.\n\t\toffset = offset - 1\n\t\tif offset < stack_top then info = nil; break end\n\t\tinfo = debug.getinfo(offset + CMD_STACK_LEVEL)\n\tuntil frame_has_line(info)\n\t\n\tif info then\n\t\tstack_inspect_offset = offset\n\t\tdbg_writeln(\"Inspecting frame: \"..format_stack_frame_info(info))\n\t\tif tonumber(dbg.auto_where) then where(info, dbg.auto_where) end\n\telse\n\t\tinfo = debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL)\n\t\tdbg_writeln(\"Already at the top of the stack.\")\n\tend\n\t\n\treturn false\nend\n\nlocal function cmd_inspect(offset)\n\toffset = stack_top + tonumber(offset)\n\tlocal info = debug.getinfo(offset + CMD_STACK_LEVEL)\n\tif info then\n\t\tstack_inspect_offset = offset\n\t\tdbg.writeln(\"Inspecting frame: \"..format_stack_frame_info(info))\n\telse\n\t\tdbg.writeln(COLOR_RED..\"ERROR: \"..COLOR_BLUE..\"Invalid stack frame index.\"..COLOR_RESET)\n\tend\nend\n\nlocal function cmd_where(context_lines)\n\tlocal info = debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL)\n\treturn (info and where(info, tonumber(context_lines) or 5))\nend\n\nlocal function cmd_trace()\n\tdbg_writeln(\"Inspecting frame %d\", stack_inspect_offset - stack_top)\n\tlocal i = 0; while true do\n\t\tlocal info = debug.getinfo(stack_top + CMD_STACK_LEVEL + i)\n\t\tif not info then break end\n\t\t\n\t\tlocal is_current_frame = (i + stack_top == stack_inspect_offset)\n\t\tlocal tab_or_caret = (is_current_frame and  GREEN_CARET or \"    \")\n\t\tdbg_writeln(COLOR_GRAY..\"% 4d\"..COLOR_RESET..tab_or_caret..\"%s\", i, format_stack_frame_info(info))\n\t\ti = i + 1\n\tend\n\t\n\treturn false\nend\n\nlocal function cmd_locals()\n\tlocal bindings = local_bindings(1, false)\n\t\n\t-- Get all the variable binding names and sort them\n\tlocal keys = {}\n\tfor k, _ in pairs(bindings) do table.insert(keys, k) end\n\ttable.sort(keys)\n\t\n\tfor _, k in ipairs(keys) do\n\t\tlocal v = bindings[k]\n\t\t\n\t\t-- Skip the debugger object itself, \"(*internal)\" values, and Lua 5.2's _ENV object.\n\t\tif not rawequal(v, dbg) and k ~= \"_ENV\" and not k:match(\"%(.*%)\") then\n\t\t\tdbg_writeln(\"  \"..COLOR_BLUE..k.. GREEN_CARET..dbg.pretty(v))\n\t\tend\n\tend\n\t\n\treturn false\nend\n\nlocal function cmd_help()\n\tdbg.write(\"\"\n\t\t..COLOR_BLUE..\"  <return>\"..GREEN_CARET..\"re-run last command\\n\"\n\t\t..COLOR_BLUE..\"  c\"..COLOR_YELLOW..\"(ontinue)\"..GREEN_CARET..\"continue execution\\n\"\n\t\t..COLOR_BLUE..\"  s\"..COLOR_YELLOW..\"(tep)\"..GREEN_CARET..\"step forward by one line (into functions)\\n\"\n\t\t..COLOR_BLUE..\"  n\"..COLOR_YELLOW..\"(ext)\"..GREEN_CARET..\"step forward by one line (skipping over functions)\\n\"\n\t\t..COLOR_BLUE..\"  f\"..COLOR_YELLOW..\"(inish)\"..GREEN_CARET..\"step forward until exiting the current function\\n\"\n\t\t..COLOR_BLUE..\"  u\"..COLOR_YELLOW..\"(p)\"..GREEN_CARET..\"move up the stack by one frame\\n\"\n\t\t..COLOR_BLUE..\"  d\"..COLOR_YELLOW..\"(own)\"..GREEN_CARET..\"move down the stack by one frame\\n\"\n\t\t..COLOR_BLUE..\"  i\"..COLOR_YELLOW..\"(nspect) \"..COLOR_BLUE..\"[index]\"..GREEN_CARET..\"move to a specific stack frame\\n\"\n\t\t..COLOR_BLUE..\"  w\"..COLOR_YELLOW..\"(here) \"..COLOR_BLUE..\"[line count]\"..GREEN_CARET..\"print source code around the current line\\n\"\n\t\t..COLOR_BLUE..\"  e\"..COLOR_YELLOW..\"(val) \"..COLOR_BLUE..\"[statement]\"..GREEN_CARET..\"execute the statement\\n\"\n\t\t..COLOR_BLUE..\"  p\"..COLOR_YELLOW..\"(rint) \"..COLOR_BLUE..\"[expression]\"..GREEN_CARET..\"execute the expression and print the result\\n\"\n\t\t..COLOR_BLUE..\"  t\"..COLOR_YELLOW..\"(race)\"..GREEN_CARET..\"print the stack trace\\n\"\n\t\t..COLOR_BLUE..\"  l\"..COLOR_YELLOW..\"(ocals)\"..GREEN_CARET..\"print the function arguments, locals and upvalues.\\n\"\n\t\t..COLOR_BLUE..\"  h\"..COLOR_YELLOW..\"(elp)\"..GREEN_CARET..\"print this message\\n\"\n\t\t..COLOR_BLUE..\"  q\"..COLOR_YELLOW..\"(uit)\"..GREEN_CARET..\"halt execution\\n\"\n\t)\n\treturn false\nend\n\nlocal last_cmd = false\n\nlocal commands = {\n\t[\"^c$\"] = function() return true end,\n\t[\"^s$\"] = cmd_step,\n\t[\"^n$\"] = cmd_next,\n\t[\"^f$\"] = cmd_finish,\n\t[\"^p%s+(.*)$\"] = cmd_print,\n\t[\"^e%s+(.*)$\"] = cmd_eval,\n\t[\"^u$\"] = cmd_up,\n\t[\"^d$\"] = cmd_down,\n\t[\"i%s*(%d+)\"] = cmd_inspect,\n\t[\"^w%s*(%d*)$\"] = cmd_where,\n\t[\"^t$\"] = cmd_trace,\n\t[\"^l$\"] = cmd_locals,\n\t[\"^h$\"] = cmd_help,\n\t[\"^q$\"] = function() dbg.exit(0); return true end,\n}\n\nlocal function match_command(line)\n\tfor pat, func in pairs(commands) do\n\t\t-- Return the matching command and capture argument.\n\t\tif line:find(pat) then return func, line:match(pat) end\n\tend\nend\n\n-- Run a command line\n-- Returns true if the REPL should exit and the hook function factory\nlocal function run_command(line)\n\t-- GDB/LLDB exit on ctrl-d\n\tif line == nil then dbg.exit(1); return true end\n\t\n\t-- Re-execute the last command if you press return.\n\tif line == \"\" then line = last_cmd or \"h\" end\n\t\n\tlocal command, command_arg = match_command(line)\n\tif command then\n\t\tlast_cmd = line\n\t\t-- unpack({...}) prevents tail call elimination so the stack frame indices are predictable.\n\t\treturn unpack({command(command_arg)})\n\telseif dbg.auto_eval then\n\t\treturn unpack({cmd_eval(line)})\n\telse\n\t\tdbg_writeln(COLOR_RED..\"Error:\"..COLOR_RESET..\" command '%s' not recognized.\\nType 'h' and press return for a command list.\", line)\n\t\treturn false\n\tend\nend\n\nrepl = function(reason)\n\t-- Skip frames without source info.\n\twhile not frame_has_line(debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL - 3)) do\n\t\tstack_inspect_offset = stack_inspect_offset + 1\n\tend\n\t\n\tlocal info = debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL - 3)\n\treason = reason and (COLOR_YELLOW..\"break via \"..COLOR_RED..reason..GREEN_CARET) or \"\"\n\tdbg_writeln(reason..format_stack_frame_info(info))\n\t\n\tif tonumber(dbg.auto_where) then where(info, dbg.auto_where) end\n\t\n\trepeat\n\t\tlocal success, done, hook = pcall(run_command, dbg.read(COLOR_RED..\"debugger.lua> \"..COLOR_RESET))\n\t\tif success then\n\t\t\tdebug.sethook(hook and hook(0), \"crl\")\n\t\telse\n\t\t\tlocal message = COLOR_RED..\"INTERNAL DEBUGGER.LUA ERROR. ABORTING\\n:\"..COLOR_RESET..\" \"..done\n\t\t\tdbg_writeln(message)\n\t\t\terror(message)\n\t\tend\n\tuntil done\nend\n\n-- Make the debugger object callable like a function.\ndbg = setmetatable({}, {\n\t__call = function(_, condition, top_offset, source)\n\t\tif condition then return end\n\t\t\n\t\ttop_offset = (top_offset or 0)\n\t\tstack_inspect_offset = top_offset\n\t\tstack_top = top_offset\n\t\t\n\t\tdebug.sethook(hook_next(1, source or \"dbg()\"), \"crl\")\n\t\treturn\n\tend,\n})\n\n-- Expose the debugger's IO functions.\ndbg.read = dbg_read\ndbg.write = dbg_write\ndbg.shorten_path = function (path) return path end\ndbg.exit = function(err) os.exit(err) end\n\ndbg.writeln = dbg_writeln\n\ndbg.pretty_depth = 3\ndbg.pretty = pretty\ndbg.pp = function(value, depth) dbg_writeln(dbg.pretty(value, depth)) end\n\ndbg.auto_where = false\ndbg.auto_eval = false\n\nlocal lua_error, lua_assert = error, assert\n\n-- Works like error(), but invokes the debugger.\nfunction dbg.error(err, level)\n\tlevel = level or 1\n\tdbg_writeln(COLOR_RED..\"ERROR: \"..COLOR_RESET..dbg.pretty(err))\n\tdbg(false, level, \"dbg.error()\")\n\t\n\tlua_error(err, level)\nend\n\n-- Works like assert(), but invokes the debugger on a failure.\nfunction dbg.assert(condition, message)\n\tmessage = message or \"assertion failed!\"\n\tif not condition then\n\t\tdbg_writeln(COLOR_RED..\"ERROR: \"..COLOR_RESET..message)\n\t\tdbg(false, 1, \"dbg.assert()\")\n\tend\n\t\n\treturn lua_assert(condition, message)\nend\n\n-- Works like pcall(), but invokes the debugger on an error.\nfunction dbg.call(f, ...)\n\treturn xpcall(f, function(err)\n\t\tdbg_writeln(COLOR_RED..\"ERROR: \"..COLOR_RESET..dbg.pretty(err))\n\t\tdbg(false, 1, \"dbg.call()\")\n\t\t\n\t\treturn err\n\tend, ...)\nend\n\n-- Error message handler that can be used with lua_pcall().\nfunction dbg.msgh(...)\n\tif debug.getinfo(2) then\n\t\tdbg_writeln(COLOR_RED..\"ERROR: \"..COLOR_RESET..dbg.pretty(...))\n\t\tdbg(false, 1, \"dbg.msgh()\")\n\telse\n\t\tdbg_writeln(COLOR_RED..\"debugger.lua: \"..COLOR_RESET..\"Error did not occur in Lua code. Execution will continue after dbg_pcall().\")\n\tend\n\t\n\treturn ...\nend\n\n-- Assume stdin/out are TTYs unless we can use LuaJIT's FFI to properly check them.\nlocal stdin_isatty = true\nlocal stdout_isatty = true\n\n-- Conditionally enable the LuaJIT FFI.\nlocal ffi = (jit and require(\"ffi\"))\nif ffi then\n\tffi.cdef[[\n\t\tint isatty(int); // Unix\n\t\tint _isatty(int); // Windows\n\t\tvoid free(void *ptr);\n\t\t\n\t\tchar *readline(const char *);\n\t\tint add_history(const char *);\n\t]]\n\t\n\tlocal function get_func_or_nil(sym)\n\t\tlocal success, func = pcall(function() return ffi.C[sym] end)\n\t\treturn success and func or nil\n\tend\n\t\n\tlocal isatty = get_func_or_nil(\"isatty\") or get_func_or_nil(\"_isatty\") or (ffi.load(\"ucrtbase\"))[\"_isatty\"]\n\tstdin_isatty = isatty(0)\n\tstdout_isatty = isatty(1)\nend\n\n-- Conditionally enable color support.\nlocal color_maybe_supported = (stdout_isatty and os.getenv(\"TERM\") and os.getenv(\"TERM\") ~= \"dumb\")\nif color_maybe_supported and not os.getenv(\"DBG_NOCOLOR\") then\n\tCOLOR_GRAY = string.char(27) .. \"[90m\"\n\tCOLOR_RED = string.char(27) .. \"[91m\"\n\tCOLOR_BLUE = string.char(27) .. \"[94m\"\n\tCOLOR_YELLOW = string.char(27) .. \"[33m\"\n\tCOLOR_RESET = string.char(27) .. \"[0m\"\n\tGREEN_CARET = string.char(27) .. \"[92m => \"..COLOR_RESET\nend\n\nif stdin_isatty and not os.getenv(\"DBG_NOREADLINE\") then\n\tpcall(function()\n\t\tlocal linenoise = require 'linenoise'\n\t\t\n\t\t-- Load command history from ~/.lua_history\n\t\tlocal hist_path = os.getenv('HOME') .. '/.lua_history'\n\t\tlinenoise.historyload(hist_path)\n\t\tlinenoise.historysetmaxlen(50)\n\t\t\n\t\tlocal function autocomplete(env, input, matches)\n\t\t\tfor name, _ in pairs(env) do\n\t\t\t\tif name:match('^' .. input .. '.*') then\n\t\t\t\t\tlinenoise.addcompletion(matches, name)\n\t\t\t\tend\n\t\t\tend\n\t\tend\n\t\t\n\t\t-- Auto-completion for locals and globals\n\t\tlinenoise.setcompletion(function(matches, input)\n\t\t\t-- First, check the locals and upvalues.\n\t\t\tlocal env = local_bindings(1, true)\n\t\t\tautocomplete(env, input, matches)\n\t\t\t\n\t\t\t-- Then, check the implicit environment.\n\t\t\tenv = getmetatable(env).__index\n\t\t\tautocomplete(env, input, matches)\n\t\tend)\n\t\t\n\t\tdbg.read = function(prompt)\n\t\t\tlocal str = linenoise.linenoise(prompt)\n\t\t\tif str and not str:match \"^%s*$\" then\n\t\t\t\tlinenoise.historyadd(str)\n\t\t\t\tlinenoise.historysave(hist_path)\n\t\t\tend\n\t\t\treturn str\n\t\tend\n\t\tdbg_writeln(COLOR_YELLOW..\"debugger.lua: \"..COLOR_RESET..\"Linenoise support enabled.\")\n\tend)\n\t\n\t-- Conditionally enable LuaJIT readline support.\n\tpcall(function()\n\t\tif dbg.read == dbg_read and ffi then\n\t\t\tlocal readline = ffi.load(\"readline\")\n\t\t\tdbg.read = function(prompt)\n\t\t\t\tlocal cstr = readline.readline(prompt)\n\t\t\t\tif cstr ~= nil then\n\t\t\t\t\tlocal str = ffi.string(cstr)\n\t\t\t\t\tif string.match(str, \"[^%s]+\") then\n\t\t\t\t\t\treadline.add_history(cstr)\n\t\t\t\t\tend\n\n\t\t\t\t\tffi.C.free(cstr)\n\t\t\t\t\treturn str\n\t\t\t\telse\n\t\t\t\t\treturn nil\n\t\t\t\tend\n\t\t\tend\n\t\t\tdbg_writeln(COLOR_YELLOW..\"debugger.lua: \"..COLOR_RESET..\"Readline support enabled.\")\n\t\tend\n\tend)\nend\n\n-- Detect Lua version.\nif jit then -- LuaJIT\n\tLUA_JIT_SETLOCAL_WORKAROUND = -1\n\tdbg_writeln(COLOR_YELLOW..\"debugger.lua: \"..COLOR_RESET..\"Loaded for \"..jit.version)\nelseif \"Lua 5.1\" <= _VERSION and _VERSION <= \"Lua 5.4\" then\n\tdbg_writeln(COLOR_YELLOW..\"debugger.lua: \"..COLOR_RESET..\"Loaded for \".._VERSION)\nelse\n\tdbg_writeln(COLOR_YELLOW..\"debugger.lua: \"..COLOR_RESET..\"Not tested against \".._VERSION)\n\tdbg_writeln(\"Please send me feedback!\")\nend\n\nreturn dbg\n";

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
