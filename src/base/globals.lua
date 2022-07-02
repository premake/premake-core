--
-- globals.lua
-- Replacements and extensions to Lua's global functions.
-- Copyright (c) 2002-2014 Jess Perkins and the Premake project
--


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
			local found = os.locate(fname[i])
			if not found then
				found = os.locate(fname[i] .. ".lua")
			end
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
--    script at that location.
---

	io._includedFiles = {}

	function include(fname)
		local actualFname, compiled_chunk = premake.findProjectScript(fname)
		if not io._includedFiles[actualFname] then
			io._includedFiles[actualFname] = true
			local success, res = pcall(compiled_chunk)
			if success then
				-- res is the return value of the script
				return res
			else
				-- res is the error message
				local caller = filelineinfo(2)
				premake.error(caller .. ": Error executing '" .. fname .. ": " .. res)
			end
		end
	end


---
-- Extend require() with a second argument to specify the expected
-- version of the loaded module. Raises an error if the version criteria
-- are not met.
--
-- @param modname
--    The name of the module to load.
-- @param versions
--    An optional version criteria string; see premake.checkVersion()
--    for more information on the format.
-- @param silent
--		By default, the require function throws an error when the
--		module could not be loaded.
--		If silent is true, the function will just return false nad the error message. 
-- @return
--    If successful, the loaded module, which is also stored into the
--    global package.loaded table.
---

	premake.override(_G, "require", function(base, modname, versions, silent)
		local result, mod = pcall(base,modname)
		if not result then
			if silent then
				return result, mod
			end
			error(mod, 3)
		end
		if mod and versions and not premake.checkVersion(mod._VERSION, versions) then
			local message = string.format("module %s %s does not meet version criteria %s",
				modname, mod._VERSION or "(none)", versions)
			if silent then
				return false, message
			end 
			error(message, 3)
		end
		return mod
	end)

	function requireopt(modname, versions)
		return require(modname, versions, true)	
	end