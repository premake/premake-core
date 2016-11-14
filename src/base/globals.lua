--
-- globals.lua
-- Replacements and extensions to Lua's global functions.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local p = premake


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
--    script at that lcoation.
---

	io._includedFiles = {}

	function include(fname)
		local fullPath = p.findProjectScript(fname)
		fname = fullPath or fname
		if not io._includedFiles[fname] then
			io._includedFiles[fname] = true
			return dofile(fname)
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

	p.override(_G, "require", function(base, modname, versions)
		local ok, mod = pcall(base, modname)
		if not ok then
			error(mod, 3)
		end

		if mod and versions and not p.checkVersion(mod._VERSION, versions) then
			error(string.format("module %s %s does not meet version criteria %s",
				modname, mod._VERSION or "(none)", versions), 3)
		end

		return mod
	end)


---
-- Returns the specified module if it exists, or `nil` otherwise.
---

	function softrequire(modname, versions)
		local loaded = table.shallowcopy(package.loaded)

		local ok, mod = pcall(require, modname, versions)

		if ok then
			return mod
		else
			package.loaded = loaded
			return nil
		end
	end
