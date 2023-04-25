---
-- tcc.lua
-- Provides Tiny C Compiler-specific configuration strings.
-- Copyright (c) 2002-2023  Perkins and the Premake project
---

	local p = premake

	p.tools.tcc = {}
	local tcc = p.tools.tcc

	local project = p.project
	local config = p.config


--
-- Returns list of C preprocessor flags for a configuration.
--

	tcc.cppflags = {
		system = {
			haiku = "-MMD",
			wii = { "-MMD", "-I$(LIBOGC_INC)", "$(MACHDEP)" },
			_ = { "-MD" }
		}
	}

	function tcc.getcppflags(cfg)
		local flags = config.mapFlags(cfg, tcc.cppflags)
		return flags
	end


--
-- Returns string to be appended to -g
--
	function tcc.getdebugformat(cfg)
		local flags = {
			Default = "",
			Dwarf = "dwarf",
		}
		return flags
	end

--
-- Returns list of C compiler flags for a configuration.
--
	tcc.shared = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			FatalCompileWarnings = "-Werror",
			LinkTimeOptimization = "-flto",
			ShadowedVariables = "-Wshadow",
			UndefinedIdentifiers = "-Wundef",
		},
		optimize = {
			Debug = "-g",
		},
		warnings = {
			Off = "-w",
			High = "-Wall",
			Extra = "-Wall -Wimplicit-function-declaration",
			Everything = "-Wall -Wimplicit-function-declaration",
		},
		symbols = function(cfg, mappings)
			local values = tcc.getdebugformat(cfg)
			local debugformat = values[cfg.debugformat] or ""
			return {
				On       = "-g" .. debugformat,
				FastLink = "-g" .. debugformat,
				Full     = "-g" .. debugformat,
			}
		end,
		unsignedchar = {
			On = "-funsigned-char",
			Off = "-fno-unsigned-char"
		},
		omitframepointer = {
			On = "-fomit-frame-pointer",
			Off = "-fno-omit-frame-pointer"
		},
	}

	tcc.cflags = {
		cdialect = {
			["C89"] = "-std=c89",
			["C90"] = "-std=c90",
			["C99"] = "-std=c99",
			["C11"] = "-std=c11",
		}
	}

	function tcc.getcflags(cfg)
		local shared_flags = config.mapFlags(cfg, tcc.shared)
		local cflags = config.mapFlags(cfg, tcc.cflags)
		local flags = table.join(shared_flags, cflags, tcc.getsystemversionflags(cfg))
		flags = table.join(flags, tcc.getwarnings(cfg))
		return flags
	end

	function tcc.getwarnings(cfg)
		local result = {}
		for _, enable in ipairs(cfg.enablewarnings) do
			table.insert(result, '-W' .. enable)
		end
		for _, disable in ipairs(cfg.disablewarnings) do
			table.insert(result, '-Wno-' .. disable)
		end
		for _, fatal in ipairs(cfg.fatalwarnings) do
			table.insert(result, '-Werror=' .. fatal)
		end
		return result
	end


--
-- Decorate defines for the tcc command line.
--

	function tcc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. p.esc(define))
		end
		return result
	end

	function tcc.getundefines(undefines)
		local result = {}
		for _, undefine in ipairs(undefines) do
			table.insert(result, '-U' .. p.esc(undefine))
		end
		return result
	end


--
-- Returns a list of forced include files, decorated for the compiler
-- command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of force include files with the appropriate flags.
--

	function tcc.getforceincludes(cfg)
		local result = {}

		table.foreachi(cfg.forceincludes, function(value)
			local fn = project.getrelative(cfg.project, value)
			table.insert(result, string.format('-include %s', p.quoted(fn)))
		end)

		return result
	end


--
-- Decorate include file search paths for the tcc command line.
--

	function tcc.getincludedirs(cfg, dirs, extdirs, frameworkdirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(frameworkdirs or {}) do
				dir = project.getrelative(cfg.project, dir)
				table.insert(result, '-F' .. p.quoted(dir))
			end
		end

		for _, dir in ipairs(extdirs or {}) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-isystem ' .. p.quoted(dir))
		end

		return result
	end

	-- relative pch file path if any
	function tcc.getpch(cfg)
		-- If there is no header, or if PCH has been disabled, I can early out
		if not cfg.pchheader or cfg.flags.NoPCH then
			return nil
		end

		-- Visual Studio requires the PCH header to be specified in the same way
		-- it appears in the #include statements used in the source code; the PCH
		-- source actual handles the compilation of the header. tcc compiles the
		-- header file directly, and needs the file's actual file system path in
		-- order to locate it.

		-- To maximize the compatibility between the two approaches, see if I can
		-- locate the specified PCH header on one of the include file search paths
		-- and, if so, adjust the path automatically so the user doesn't have
		-- add a conditional configuration to the project script.

		local pch = cfg.pchheader
		local found = false

		-- test locally in the project folder first (this is the most likely location)
		local testname = path.join(cfg.project.basedir, pch)
		if os.isfile(testname) then
			return project.getrelative(cfg.project, testname)
		else
			-- else scan in all include dirs.
			for _, incdir in ipairs(cfg.includedirs) do
				testname = path.join(incdir, pch)
				if os.isfile(testname) then
					return project.getrelative(cfg.project, testname)
				end
			end
		end

		return project.getrelative(cfg.project, path.getabsolute(pch))
	end

--
-- Return a list of decorated rpaths
--
-- @param cfg
--    The configuration to query.
-- @param dirs
--    List of absolute paths
-- @param mode
--    Output mode
--    - "linker" (default) Linker rpath instructions
--    - "path" List of path relative to configuration target directory
--

	function tcc.getrunpathdirs(cfg, dirs, mode)
		local result = {}
		mode = iif (mode == nil, "linker", mode)

		if not (table.contains(os.getSystemTags(cfg.system), "darwin")
				or (cfg.system == p.LINUX)) then
			return result
		end

		for _, fullpath in ipairs(dirs) do
			local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
			if table.contains(os.getSystemTags(cfg.system), "darwin") then
				rpath = "@loader_path/" .. rpath
			elseif (cfg.system == p.LINUX) then
				rpath = iif(rpath == ".", "", "/" .. rpath)
				rpath = "$$ORIGIN" .. rpath
			end

			if mode == "linker" then
				rpath = "-Wl,-rpath,'" .. rpath .. "'"
			end

			table.insert(result, rpath)
		end

		return result
	end

--
-- get the right output flag.
--
	function tcc.getsharedlibarg(cfg)
		if table.contains(os.getSystemTags(cfg.system), "darwin") then
--			 ?
			return "-dynamiclib"
		else
			return "-shared"
		end
	end


--
-- Return a list of LDFLAGS for a specific configuration.
--

	function tcc.ldsymbols(cfg)
		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		return iif(table.contains(os.getSystemTags(cfg.system), "darwin"), "-Wl,-x", "-s")
	end

	tcc.ldflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		kind = {
			SharedLib = function(cfg)
				return { tcc.getsharedlibarg(cfg) }
			end,
			WindowedApp = function(cfg)
				if cfg.system == p.WINDOWS then return "-mwindows" end
			end,
		},
		system = {
			wii = "$(MACHDEP)",
		},
		symbols = {
			Off = tcc.ldsymbols,
			Default = tcc.ldsymbols,
		}
	}

	function tcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, tcc.ldflags)
		return flags
	end



--
-- Return a list of decorated additional libraries directories.
--

	tcc.libraryDirectories = {
		architecture = {
			x86 = function (cfg)
				local r = {}
				if not table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert (r, "-L/usr/lib32")
				end
				return r
			end,
			x86_64 = function (cfg)
				local r = {}
				if not table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert (r, "-L/usr/lib64")
				end
				return r
			end,
		},
		system = {
			wii = "-L$(LIBOGC_LIB)",
		}
	}

	function tcc.getLibraryDirectories(cfg)
		local flags = {}

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths. The call
		-- config.getlinks() all includes cfg.libdirs.
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(cfg.frameworkdirs) do
				dir = project.getrelative(cfg.project, dir)
				table.insert(flags, '-F' .. p.quoted(dir))
			end
		end

		if cfg.flags.RelativeLinks then
			for _, dir in ipairs(config.getlinks(cfg, "siblings", "directory")) do
				local libFlag = "-L" .. p.project.getrelative(cfg.project, dir)
				if not table.contains(flags, libFlag) then
					table.insert(flags, libFlag)
				end
			end
		end

		for _, dir in ipairs(cfg.syslibdirs) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		local tccFlags = config.mapFlags(cfg, tcc.libraryDirectories)
		flags = table.join(flags, tccFlags)

		return flags
	end



--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function tcc.getlinks(cfg, systemonly, nogroups)
		local result = {}

		if not systemonly then
			if cfg.flags.RelativeLinks then
				local libFiles = config.getlinks(cfg, "siblings", "basename")
				for _, link in ipairs(libFiles) do
					if string.startswith(link, "lib") then
						link = link:sub(4)
					end
					table.insert(result, "-l" .. link)
				end
			else
				-- Don't use the -l form for sibling libraries, since they may have
				-- custom prefixes or extensions that will confuse the linker. Instead
				-- just list out the full relative path to the library.
				result = config.getlinks(cfg, "siblings", "fullpath")
			end
		end

		-- The "-l" flag is fine for system libraries
		local links = config.getlinks(cfg, "system", "fullpath")
		local static_syslibs = {"-Wl,-Bstatic"}
		local shared_syslibs = {}

		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				local endswith = function(s, ptrn)
					return ptrn == string.sub(s, -string.len(ptrn))
				end
				local name = path.getname(link)
				-- Check whether link mode decorator is present
				if endswith(name, ":static") then
					name = string.sub(name, 0, -8)
					table.insert(static_syslibs, "-l" .. name)
				elseif endswith(name, ":shared") then
					name = string.sub(name, 0, -8)
					table.insert(shared_syslibs, "-l" .. name)
				else
					table.insert(shared_syslibs, "-l" .. name)
				end
			end
		end

		local move = function(a1, a2)
			local t = #a2
			for i = 1, #a1 do a2[t + i] = a1[i] end
		end
		if #static_syslibs > 1 then
			table.insert(static_syslibs, "-Wl,-Bdynamic")
			move(static_syslibs, result)
		end
		move(shared_syslibs, result)

		if not nogroups and #result > 1 and (cfg.linkgroups == p.ON) then
			table.insert(result, 1, "-Wl,--start-group")
			table.insert(result, "-Wl,--end-group")
		end

		return result
	end


--
-- Returns makefile-specific configuration rules.
--

	tcc.makesettings = {
		system = {
			wii = [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules']]
		}
	}

	function tcc.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, tcc.makesettings)
		return table.concat(settings)
	end


--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "cc" for the C compiler, "cxx" for
--    the C++ compiler, or "ar" for the static linker.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

	tcc.tools = {
		cc = "tcc",
		ar = "ar",
		rc = "windres"
	}

	function tcc.gettoolname(cfg, tool)
		if (cfg.tccprefix and tcc.tools[tool]) or tool == "rc" then
			return (cfg.tccprefix or "") .. tcc.tools[tool]
		end
		return nil
	end
