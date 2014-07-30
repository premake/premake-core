--
-- globals.lua
-- Replacements and extensions to Lua's global functions.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--


---
-- Helper for the dofile() and include() function: locate a script on the
-- standard search paths of: the /scripts argument provided on the command
-- line, then the PREMAKE_PATH environment variable.
--
-- @param ...
--    A list of file names for which to search. The first one discovered
--    is the one that will be returned.
-- @return
--    The path to file if found, or nil if not.
---

	local function locate(...)
		local function find(fname)
			-- is this a direct path to a file?
			if os.isfile(fname) then
				return fname
			end

			-- find it on my paths
			local dir = os.pathsearch(fname, _OPTIONS["scripts"], os.getenv("PREMAKE_PATH"), path.getdirectory(_PREMAKE_COMMAND))
			if dir then
				return path.join(dir, fname)
			end
		end

		for i = 1, select("#",...) do
			local fname = select(i, ...)
			local result = find(fname)
			if not result then
				result = find(fname .. ".lua")
			end
			if result then
				return result
			end
		end
	end



---
-- A replacement for Lua's built-in dofile() function that knows how to
-- search for script files. Note that I've also modified luaL_loadfile()
-- in src/host/lua_auxlib.c to set the _SCRIPT variable and adjust the
-- working directory.
---

	local builtin_dofile = dofile

	function dofile(fname)
		fname = locate(fname) or fname
		return builtin_dofile(fname)
	end



--
-- Find and execute a Lua source file present on the filesystem, but
-- continue without error if the file is not present. This is used to
-- handle optional files such as the premake-system.lua script.
--
-- @param fname
--    The name of the file to load. This may be specified as a single
--    file path or an array of file paths, in which case the first
--    file found is run.
-- @return
--    True if a file was found and executed, nil otherwise.
--

	function dofileopt(fname)
		if type(fname) == "string" then fname = {fname} end
		for i = 1, #fname do
			local found = locate(fname[i])
			if found then
				dofile(found)
				return true
			end
		end
	end



---
-- Load and run an external script file, with a bit of extra logic to make
-- including projects easier. if "path" is a directory, will look for
-- path/premake5.lua. And each file is tracked, and loaded only once.
--
-- @param fname
--    The name of the directory or file to include. If a directory, will
--    automatically include the contained premake5.lua or premake4.lua
--    script at that lcoation.
---

	io._includedFiles = {}

	function include(fname)
		local found = locate(fname, path.join(fname, "premake5.lua"), path.join(fname, "premake4.lua"))

		-- only include each file once
		fname = path.getabsolute(found or fname)
		if not io._includedFiles[fname] then
			io._includedFiles[fname] = true
			dofile(fname)
		end
	end
