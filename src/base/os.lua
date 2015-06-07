--
-- os.lua
-- Additions to the OS namespace.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--


---
-- Extend Lua's built-in os.execute() with token expansion and
-- path normalization.
--

	premake.override(os, "execute", function(base, cmd)
		cmd = path.normalize(cmd)
		cmd = os.translateCommands(cmd)
		return base(cmd)
	end)



---
-- Same as os.execute(), but accepts string formatting arguments.
---

	function os.executef(cmd, ...)
		cmd = string.format(cmd, ...)
		return os.execute(cmd)
	end



--
-- Scan the well-known system locations for a particular library.
--

	local function parse_ld_so_conf(conf_file)
		-- Linux ldconfig file parser to find system library locations
		local first, last
		local dirs = { }
		for line in io.lines(conf_file) do
			-- ignore comments
			first = line:find("#", 1, true)
			if first ~= nil then
				line = line:sub(1, first - 1)
			end

			if line ~= "" then
				-- check for include files
				first, last = line:find("include%s+")
				if first ~= nil then
					-- found include glob
					local include_glob = line:sub(last + 1)
					local includes = os.matchfiles(include_glob)
					for _, v in ipairs(includes) do
						dirs = table.join(dirs, parse_ld_so_conf(v))
					end
				else
					-- found an actual ld path entry
					table.insert(dirs, line)
				end
			end
		end
		return dirs
	end

	function os.findlib(libname, libdirs)
		-- libname: library name with or without prefix and suffix
		-- libdirs: (array or string): A set of additional search paths
				 
		local path, formats

		-- assemble a search path, depending on the platform
		if os.is("windows") then
			formats = { "%s.dll", "%s" }
			path = os.getenv("PATH") or ""
		elseif os.is("haiku") then
			formats = { "lib%s.so", "%s.so" }
			path = os.getenv("LIBRARY_PATH") or ""
		else
			if os.is("macosx") then
				formats = { "lib%s.dylib", "%s.dylib" }
				path = os.getenv("DYLD_LIBRARY_PATH") or ""
			else
				formats = { "lib%s.so", "%s.so" }
				path = os.getenv("LD_LIBRARY_PATH") or ""

				for _, prefix in ipairs({"", "/opt"}) do
					local conf_file = prefix .. "/etc/ld.so.conf"
					if os.isfile(conf_file) then
						for _, v in ipairs(parse_ld_so_conf(conf_file)) do
							if (#path > 0) then 
								path = path .. ":" .. v
							else
								path = v
							end
						end
					end
				end
			end

			table.insert(formats, "%s")
			path = path or ""
			local archpath = "/lib:/usr/lib:/usr/local/lib"
			if os.is64bit() then
				archpath = "/lib64:/usr/lib64/:usr/local/lib64" .. ":" .. archpath
			end
			if (#path > 0) then
				path = path .. ":" .. archpath
			else
				path = archpath
			end
		end

		local userpath = ""
		
		if type(libdirs) == "string" then
			userpath = libdirs
		elseif type(libdirs) == "table" then
			userpath = table.implode(libdirs, "", "", ":")
		end
	
		if (#userpath > 0) then
			if (#path > 0) then
				path = userpath .. ":" .. path
			else
				path = userpath
			end
		end
		
		for _, fmt in ipairs(formats) do
			local name = string.format(fmt, libname)
			local result = os.pathsearch(name, path)
			if result then return result end
		end
	end



--
-- Retrieve the current operating system ID string.
--

	function os.get()
		return _OPTIONS.os or _OS
	end



--
-- Check the current operating system; may be set with the /os command line flag.
--

	function os.is(id)
		return (os.get():lower() == id:lower())
	end



---
-- Determine if a directory exists on the file system, and that it is a
-- directory and not a file.
--
-- @param p
--    The path to check.
-- @return
--    True if a directory exists at the given path.
---

	premake.override(os, "isdir", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



---
-- Determine if a file exists on the file system, and that it is a
-- file and not a directory.
--
-- @param p
--    The path to check.
-- @return
--    True if a file exists at the given path.
---

	premake.override(os, "isfile", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



--
-- Determine if the current system is running a 64-bit architecture.
--

	local _is64bit

	local _64BitHostTypes = {
		"x86_64",
		"ia64",
		"amd64",
		"ppc64",
		"powerpc64",
		"sparc64"
	}

	function os.is64bit()
		-- This can be expensive to compute, so cache and reuse the response
		if _is64bit ~= nil then
			return _is64bit
		end

		_is64bit = false

		-- Call the native code implementation. If this returns true then
		-- we're 64-bit, otherwise do more checking locally
		if (os._is64bit()) then
			_is64bit = true
		else
			-- Identify the system
			local arch
			if _OS == "windows" then
				arch = os.getenv("PROCESSOR_ARCHITECTURE")
			elseif _OS == "macosx" then
				arch = os.outputof("echo $HOSTTYPE")
			else
				arch = os.outputof("uname -m")
			end

			-- Check our known 64-bit identifiers
			arch = arch:lower()
			for _, hosttype in ipairs(_64BitHostTypes) do
				if arch:find(hosttype) then
					_is64bit = true
				end
			end
		end

		return _is64bit
	end



---
-- Perform a wildcard search for files or directories.
--
-- @param mask
--    The file search pattern. Use "*" to match any part of a file or
--    directory name, "**" to recurse into subdirectories.
-- @param matchFiles
--    True to match against files, false to match directories.
-- @return
--    A table containing the matched file or directory names.
---

	function os.match(mask, matchFiles)
		-- Strip any extraneous weirdness from the mask to ensure a good
		-- match against the paths returned by the OS. I don't know if I've
		-- caught all the possibilities here yet; will add more as I go.

		mask = path.normalize(mask)

		-- strip off any leading directory information to find out
		-- where the search should take place

		local basedir = mask
		local starpos = mask:find("%*")
		if starpos then
			basedir = basedir:sub(1, starpos - 1)
		end
		basedir = path.getdirectory(basedir)
		if basedir == "." then
			basedir = ""
		end

		-- recurse into subdirectories?
		local recurse = mask:find("**", nil, true)

		-- convert mask to a Lua pattern
		mask = path.wildcards(mask)

		local result = {}

		local function matchwalker(basedir)
			local wildcard = path.join(basedir, "*")

			-- retrieve files from OS and test against mask
			local m = os.matchstart(wildcard)
			while os.matchnext(m) do
				local isfile = os.matchisfile(m)
				if (matchFiles and isfile) or (not matchFiles and not isfile) then
					local fname = os.matchname(m)
					if isfile or not fname:startswith(".") then
						fname = path.join(basedir, fname)
						if fname:match(mask) == fname then
							table.insert(result, fname)
						end
					end
				end
			end
			os.matchdone(m)

			-- check subdirectories
			if recurse then
				m = os.matchstart(wildcard)
				while os.matchnext(m) do
					if not os.matchisfile(m) then
						local dirname = os.matchname(m)
						if (not dirname:startswith(".")) then
							matchwalker(path.join(basedir, dirname))
						end
					end
				end
				os.matchdone(m)
			end
		end

		matchwalker(basedir)
		return result
	end


---
-- Perform a wildcard search for directories.
--
-- @param mask
--    The search pattern. Use "*" to match any part of a directory
--    name, "**" to recurse into subdirectories.
-- @return
--    A table containing the matched directory names.
---

	function os.matchdirs(mask)
		return os.match(mask, false)
	end


---
-- Perform a wildcard search for files.
--
-- @param mask
--    The search pattern. Use "*" to match any part of a file
--    name, "**" to recurse into subdirectories.
-- @return
--    A table containing the matched directory names.
---

	function os.matchfiles(mask)
		return os.match(mask, true)
	end


--
-- An overload of the os.mkdir() function, which will create any missing
-- subdirectories along the path.
--

	local builtin_mkdir = os.mkdir
	function os.mkdir(p)
		p = path.normalize(p)

		local dir = iif(p:startswith("/"), "/", "")
		for part in p:gmatch("[^/]+") do
			dir = dir .. part

			if (part ~= "" and not path.isabsolute(part) and not os.isdir(dir)) then
				local ok, err = builtin_mkdir(dir)
				if (not ok) then
					return nil, err
				end
			end

			dir = dir .. "/"
		end

		return true
	end


--
-- Run a shell command and return the output.
--

	function os.outputof(cmd)
		cmd = path.normalize(cmd)

		local pipe = io.popen(cmd)
		local result = pipe:read('*a')
		local b, exitcode = pipe:close()
		if not b then
			exitcode = -1
		end

		return result, exitcode
	end


--
-- @brief An overloaded os.remove() that will be able to handle list of files,
--        as well as wildcards for files. Uses the syntax os.matchfiles() for
--        matching pattern wildcards.
--
-- @param f A file, a wildcard, or a list of files or wildcards to be removed
--
-- @return true on success, false and an appropriate error message on error
--
-- @example     ok, err = os.remove{"**.bak", "**.log"}
--              if not ok then
--                  error(err)
--              end
--

	local builtin_remove = os.remove
	function os.remove(f)
		-- in case of string, just match files
		if type(f) == "string" then
			local p = os.matchfiles(f)
			for _, v in pairs(p) do
				local ok, err = builtin_remove(v)
				if not ok then
					return ok, err
				end
			end
		-- in case of table, match files for every table entry
		elseif type(f) == "table" then
			for _, v in pairs(f) do
				local ok, err = os.remove(v)
				if not ok then
					return ok, err
				end
			end
		end
	end


--
-- Remove a directory, along with any contained files or subdirectories.
--

	local builtin_rmdir = os.rmdir
	function os.rmdir(p)
		-- recursively remove subdirectories
		local dirs = os.matchdirs(p .. "/*")
		for _, dname in ipairs(dirs) do
			os.rmdir(dname)
		end

		-- remove any files
		local files = os.matchfiles(p .. "/*")
		for _, fname in ipairs(files) do
			os.remove(fname)
		end

		-- remove this directory
		builtin_rmdir(p)
	end


---
-- Return information about a file.
---

	premake.override(os, "stat", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



---
-- Translate command tokens into their OS or action specific equivalents.
---

	os.commandTokens = {
		_ = {
			chdir = function(v)
				return "cd " .. v
			end,
			copy = function(v)
				return "cp -rf " .. v
			end,
			delete = function(v)
				return "rm -f " .. v
			end,
			echo = function(v)
				return "echo " .. v
			end,
			mkdir = function(v)
				return "mkdir -p " .. v
			end,
			move = function(v)
				return "mv -f " .. v
			end,
			rmdir = function(v)
				return "rm -rf " .. v
			end,
			touch = function(v)
				return "touch " .. v
			end,
		},
		windows = {
			chdir = function(v)
				return "chdir " .. path.translate(v)
			end,
			copy = function(v)
				return "xcopy /Q /E /Y /I " .. path.translate(v) .. " > nul"
			end,
			delete = function(v)
				return "del " .. path.translate(v)
			end,
			echo = function(v)
				return "echo " .. v
			end,
			mkdir = function(v)
				return "mkdir " .. path.translate(v)
			end,
			move = function(v)
				return "move /Y " .. path.translate(v)
			end,
			rmdir = function(v)
				return "rmdir /S /Q " .. path.translate(v)
			end,
			touch = function(v)
				v = path.translate(v)
				return string.format("type nul >> %s && copy /b %s+,, %s", v, v, v)
			end,
		}
	}

	function os.translateCommands(cmd, map)
		map = map or os.get()
		if type(map) == "string" then
			map = os.commandTokens[map] or os.commandTokens["_"]
		end

		local processOne = function(cmd)
			local token = cmd:match("^{.+}")
			if token then
				token = token:sub(2, #token - 1):lower()
				local args = cmd:sub(#token + 4)
				local func = map[token] or os.commandTokens["_"][token]
				if func then
					cmd = func(args)
				end
			end
			return cmd
		end

		if type(cmd) == "table" then
			local result = {}
			for i = 1, #cmd do
				result[i] = processOne(cmd[i])
			end
			return result
		else
			return processOne(cmd)
		end
	end



--
-- Generate a UUID.
--

	os._uuids = {}

	local builtin_uuid = os.uuid
	function os.uuid(name)
		local id = builtin_uuid(name)
		if name then
			if os._uuids[id] and os._uuids[id] ~= name then
				premake.warnOnce(id, "UUID clash between %s and %s", os._uuids[id], name)
			end
			os._uuids[id] = name
		end
		return id
	end


--
-- Allows copying directories.
-- NOTE: It won't copy empty directories!
-- Example: we have a file: src/test.h
--	os.copydir("src", "include") simple copy, makes include/test.h
--	os.copydir("src", "include", "*.h") makes include/test.h
--	os.copydir(".", "include", "src/*.h") makes include/src/test.h
--	os.copydir(".", "include", "**.h") makes include/src/test.h
--	os.copydir(".", "include", "**.h", true) will force it to include dir, makes include/test.h
--
-- @param src_dir
--    Source directory, which will be copied to dst_dir.
-- @param dst_dir
--    Destination directory.
-- @param filter
--    Optional, defaults to "**". Only filter matches will be copied. It can contain **(recursive) and *(filename).
-- @param single_dst_dir
--    Optional, defaults to false. Allows putting all files to dst_dir without subdirectories.
--    Only useful with recursive (**) filter.
-- @returns
--    True if successful, otherwise nil.
--
	function os.copydir(src_dir, dst_dir, filter, single_dst_dir)
		if not os.isdir(src_dir) then error(src_dir .. " is not an existing directory!") end
		filter = filter or "**"
		src_dir = src_dir .. "/"
		print('copy "' .. src_dir .. filter .. '" to "' .. dst_dir .. '".')
		dst_dir = dst_dir .. "/"
		local dir = path.rebase(".",path.getabsolute("."), src_dir) -- root dir, relative from src_dir
 
		os.chdir( src_dir ) -- change current directory to src_dir
			local matches = os.matchfiles(filter)
		os.chdir( dir ) -- change current directory back to root
 
		local counter = 0
		for k, v in ipairs(matches) do
			local target = iif(single_dst_dir, path.getname(v), v)
			--make sure, that directory exists or os.copyfile() fails
			os.mkdir( path.getdirectory(dst_dir .. target))
			if os.copyfile( src_dir .. v, dst_dir .. target) then
				counter = counter + 1
			end
		end
 
		if counter == #matches then
			print( counter .. " files copied.")
			return true
		else
			print( "Error: " .. counter .. "/" .. #matches .. " files copied.")
			return nil
		end
	end
