--
-- globals.lua
-- Replacements and extensions to Lua's global functions.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
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
		local findOK, foundFnameOrErr, compiled_chunk = pcall(function () return premake.findProjectScript(fname) end)
		if findOK then
			local actualFname = foundFnameOrErr
			if not io._includedFiles[actualFname] then
				io._includedFiles[actualFname] = true
				local callOK, res = pcall(compiled_chunk)
				if callOK then
					-- res is the return value of the script
					return res
				else
					local err = res
					local caller = filelineinfo(2)
					premake.error(caller .. ": include(" .. fname .. ") execution error: " .. err)
				end
			end
		else
			local err = foundFnameOrErr
			local caller = filelineinfo(2)
			premake.error(caller .. ": include(" .. fname .. ") not found: " .. err)
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
-- @return
--    If successful, the loaded module, which is also stored into the
--    global package.loaded table.
---

	premake.override(_G, "require", function(base, modname, versions)
		local result, mod = pcall(base,modname)
		if not result then
			error(mod, 3)
		end
		if mod and versions and not premake.checkVersion(mod._VERSION, versions) then
			error(string.format("module %s %s does not meet version criteria %s",
				modname, mod._VERSION or "(none)", versions), 3)
		end
		return mod
	end)
