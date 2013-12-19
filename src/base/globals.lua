--
-- globals.lua
-- Replacements and extensions to Lua's global functions.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--


--
-- Helper for the dofile() and include() function: locate a script on the
-- standard search paths of: the /scripts argument provided on the command
-- line, then the PREMAKE_PATH environment variable.
--
-- @param ...
--    A list of file names for which to search. The first one discovered
--    is the one that will be returned.
-- @return
--    The path to file if found, or nil if not.
--

	local function locate(...)
		for i = 1, select("#",...) do
			local fname = select(i,...)

			-- is this a direct path to a file?
			if os.isfile(fname) then
				return fname
			end

			-- find it on my paths
			local dir = os.pathsearch(fname, _OPTIONS["scripts"], os.getenv("PREMAKE_PATH"))
			if dir then
				return path.join(dir, fname)
			end
		end
	end


--
-- A replacement for Lua's built-in dofile() function, this one sets the
-- current working directory to the script's location, enabling script-relative
-- referencing of other files and resources.
--

	local builtin_dofile = dofile

	function dofile(fname)
		-- remember the current working directory and file; I'll restore it shortly
		local oldcwd = os.getcwd()
		local oldfile = _SCRIPT

		-- find it; if I can't just continue with the name and let the
		-- built-in dofile() handle reporting the error as it will
		fname = locate(fname) or fname

		-- use the absolute path to the script file, to avoid any file name
		-- ambiguity if an error should arise
		_SCRIPT = path.getabsolute(fname)

		-- switch the working directory to the new script location
		local newcwd = path.getdirectory(_SCRIPT)
		os.chdir(newcwd)

		-- run the chunk. How can I catch variable return values?
		local a, b, c, d, e, f = builtin_dofile(_SCRIPT)

		-- restore the previous working directory when done
		_SCRIPT = oldfile
		os.chdir(oldcwd)
		return a, b, c, d, e, f
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



--
-- Load and run an external script file, with a bit of extra logic to make
-- including projects easier. if "path" is a directory, will look for
-- path/premake5.lua. And each file is tracked, and loaded only once.
--

	io._includedFiles = {}

	function include(fname)
		local found = locate(fname)
		if not found then
			found = locate(path.join(fname, "premake5.lua"))
		end
		if not found then
			found = locate(path.join(fname, "premake4.lua"))
		end

		-- but only load each file once
		fname = path.getabsolute(found or fname)
		if not io._includedFiles[fname] then
			io._includedFiles[fname] = true
			dofile(fname)
		end
	end
