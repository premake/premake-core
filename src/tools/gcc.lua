---
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake

	p.tools.gcc = {}
	local gcc = p.tools.gcc

	local project = p.project
	local config = p.config


--
-- Returns list of C preprocessor flags for a configuration.
--

	gcc.cppflags = {
		system = {
			haiku = "-MMD",
			wii = { "-MMD", "-MP", "-I$(LIBOGC_INC)", "$(MACHDEP)" },
			_ = { "-MD", "-MP" }
		}
	}

	function gcc.getcppflags(cfg)
		local flags = config.mapFlags(cfg, gcc.cppflags)
		return flags
	end


--
-- Returns string to be appended to -g
--
	function gcc.getdebugformat(cfg)
		local flags = {
			Default = "",
			Dwarf = "dwarf",
			SplitDwarf = "split-dwarf",
		}
		return flags
	end

--
-- Returns list of C compiler flags for a configuration.
--
	gcc.shared = {
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
		floatingpoint = {
			Fast = "-ffast-math",
			Strict = "-ffloat-store",
		},
		strictaliasing = {
			Off = "-fno-strict-aliasing",
			Level1 = { "-fstrict-aliasing", "-Wstrict-aliasing=1" },
			Level2 = { "-fstrict-aliasing", "-Wstrict-aliasing=2" },
			Level3 = { "-fstrict-aliasing", "-Wstrict-aliasing=3" },
		},
		openmp = {
			On = "-fopenmp"
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Debug = "-Og",
			Full = "-O3",
			Size = "-Os",
			Speed = "-O3",
		},
		pic = {
			On = "-fPIC",
		},
		vectorextensions = {
			AVX = "-mavx",
			AVX2 = "-mavx2",
			SSE = "-msse",
			SSE2 = "-msse2",
			SSE3 = "-msse3",
			SSSE3 = "-mssse3",
			["SSE4.1"] = "-msse4.1",
			["SSE4.2"] = "-msse4.2",
		},
		isaextensions = {
			MOVBE = "-mmovbe",
			POPCNT = "-mpopcnt",
			PCLMUL = "-mpclmul",
			LZCNT = "-mlzcnt",
			BMI = "-mbmi",
			BMI2 = "-mbmi2",
			F16C = "-mf16c",
			AES = "-maes",
			FMA = "-mfma",
			FMA4 = "-mfma4",
			RDRND = "-mrdrnd",
		},
		warnings = {
			Off = "-w",
			High = "-Wall",
			Extra = {"-Wall", "-Wextra"},
			Everything = "-Weverything",
		},
		externalwarnings = {
			Default = "-Wsystem-headers",
			High = "-Wsystem-headers",
			Extra = "-Wsystem-headers",
			Everything = "-Wsystem-headers",
		},
		symbols = function(cfg, mappings)
			local values = gcc.getdebugformat(cfg)
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
		compileas = {
			["C"] = "-x c",
			["C++"] = "-x c++",
			["Objective-C"] = "-x objective-c",
			["Objective-C++"] = "-x objective-c++",
		},
		sanitize = {
			Address = "-fsanitize=address",
		},
		visibility = {
			Default = "-fvisibility=default",
			Hidden = "-fvisibility=hidden",
			Internal = "-fvisibility=internal",
			Protected = "-fvisibility=protected",
		},
		inlinesvisibility = {
			Hidden = "-fvisibility-inlines-hidden"
		}
	}

	gcc.cflags = {
		cdialect = {
			["C89"] = "-std=c89",
			["C90"] = "-std=c90",
			["C99"] = "-std=c99",
			["C11"] = "-std=c11",
			["C17"] = "-std=c17",
			["gnu89"] = "-std=gnu89",
			["gnu90"] = "-std=gnu90",
			["gnu99"] = "-std=gnu99",
			["gnu11"] = "-std=gnu11",
			["gnu17"] = "-std=gnu17"
		}
	}

	function gcc.getcflags(cfg)
		local shared_flags = config.mapFlags(cfg, gcc.shared)
		local cflags = config.mapFlags(cfg, gcc.cflags)
		local flags = table.join(shared_flags, cflags, gcc.getsystemversionflags(cfg))
		flags = table.join(flags, gcc.getwarnings(cfg))
		return flags
	end

	function gcc.getwarnings(cfg)
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
-- Returns C/C++ system version build flags
--

	function gcc.getsystemversionflags(cfg)
		local flags = {}

		if cfg.system == p.MACOSX then
			local minVersion = p.project.systemversion(cfg)
			if minVersion ~= nil then
				table.insert (flags, "-mmacosx-version-min=" .. minVersion)
			end
		end

		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	gcc.cxxflags = {
		exceptionhandling = {
			Off = "-fno-exceptions"
		},
		flags = {
			NoBufferSecurityCheck = "-fno-stack-protector",
		},
		cppdialect = {
			["C++98"] = "-std=c++98",
			["C++0x"] = "-std=c++0x",
			["C++11"] = "-std=c++11",
			["C++1y"] = "-std=c++1y",
			["C++14"] = "-std=c++14",
			["C++1z"] = "-std=c++1z",
			["C++17"] = "-std=c++17",
			["C++2a"] = "-std=c++2a",
			["C++20"] = "-std=c++20",
			["gnu++98"] = "-std=gnu++98",
			["gnu++0x"] = "-std=gnu++0x",
			["gnu++11"] = "-std=gnu++11",
			["gnu++1y"] = "-std=gnu++1y",
			["gnu++14"] = "-std=gnu++14",
			["gnu++1z"] = "-std=gnu++1z",
			["gnu++17"] = "-std=gnu++17",
			["gnu++2a"] = "-std=gnu++2a",
			["gnu++20"] = "-std=gnu++20",
			["C++latest"] = "-std=c++20",
		},
		rtti = {
			Off = "-fno-rtti"
		}
	}

	function gcc.getcxxflags(cfg)
		local shared_flags = config.mapFlags(cfg, gcc.shared)
		local cxxflags = config.mapFlags(cfg, gcc.cxxflags)
		local flags = table.join(shared_flags, cxxflags)
		flags = table.join(flags, gcc.getwarnings(cfg), gcc.getsystemversionflags(cfg))
		return flags
	end


--
-- Decorate defines for the GCC command line.
--

	function gcc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. p.esc(define))
		end
		return result
	end

	function gcc.getundefines(undefines)
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

	function gcc.getforceincludes(cfg)
		local result = {}

		table.foreachi(cfg.forceincludes, function(value)
			local fn = p.tools.getrelative(cfg.project, value)
			table.insert(result, string.format('-include %s', p.quoted(fn)))
		end)

		return result
	end


--
-- Returns a list of include file search directories, decorated for
-- the compiler command line.
--
-- @param cfg
--    The project configuration.
-- @param dirs
--    An array of include file search directories; as an array of
--    string values.
-- @param extdirs
--    An array of include file search directories for external includes;
--    as an array of string values.
-- @param frameworkdirs
--    An array of file search directories for the framework includes;
--    as an array of string vlaues
-- @param includedirsafter
--    An array of include file search directories for includes after system;
--    as an array of string values.
-- @return
--    An array of symbols with the appropriate flag decorations.
--

	function gcc.getincludedirs(cfg, dirs, extdirs, frameworkdirs, includedirsafter)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = p.tools.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(frameworkdirs or {}) do
				dir = p.tools.getrelative(cfg.project, dir)
				table.insert(result, '-F' .. p.quoted(dir))
			end
		end

		for _, dir in ipairs(extdirs or {}) do
			dir = p.tools.getrelative(cfg.project, dir)
			table.insert(result, '-isystem ' .. p.quoted(dir))
		end

		for _, dir in ipairs(includedirsafter or {}) do
			dir = p.tools.getrelative(cfg.project, dir)
			table.insert(result, '-idirafter ' .. p.quoted(dir))
		end

		return result
	end

	-- relative pch file path if any
	function gcc.getpch(cfg)
		-- If there is no header, or if PCH has been disabled, I can early out
		if not cfg.pchheader or cfg.flags.NoPCH then
			return nil
		end

		-- Visual Studio requires the PCH header to be specified in the same way
		-- it appears in the #include statements used in the source code; the PCH
		-- source actual handles the compilation of the header. GCC compiles the
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
			return p.tools.getrelative(cfg.project, testname)
		else
			-- else scan in all include dirs.
			for _, incdir in ipairs(cfg.includedirs) do
				testname = path.join(incdir, pch)
				if os.isfile(testname) then
					return p.tools.getrelative(cfg.project, testname)
				end
			end
		end

		return p.tools.getrelative(cfg.project, path.getabsolute(pch))
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

	function gcc.getrunpathdirs(cfg, dirs, mode)
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
	function gcc.getsharedlibarg(cfg)
		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			if cfg.sharedlibtype == "OSXBundle" then
				return "-bundle"
			elseif cfg.sharedlibtype == "XCTest" then
				return "-bundle"
			elseif cfg.sharedlibtype == "OSXFramework" then
				return "-framework"
			else
				return "-dynamiclib"
			end
		else
			return "-shared"
		end
	end


--
-- Return a list of LDFLAGS for a specific configuration.
--

	function gcc.ldsymbols(cfg)
		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		return iif(table.contains(os.getSystemTags(cfg.system), "darwin"), "-Wl,-x", "-s")
	end

	gcc.ldflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			LinkTimeOptimization = "-flto",
		},
		kind = {
			SharedLib = function(cfg)
				local r = { gcc.getsharedlibarg(cfg) }
				if cfg.system == p.WINDOWS and not cfg.flags.NoImportLib then
					table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
				elseif cfg.system == p.LINUX then
					table.insert(r, '-Wl,-soname=' .. p.quoted(cfg.linktarget.name))
				elseif table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert(r, '-Wl,-install_name,' .. p.quoted('@rpath/' .. cfg.linktarget.name))
				end
				return r
			end,
			WindowedApp = function(cfg)
				if cfg.system == p.WINDOWS then return "-mwindows" end
			end,
		},
		linker = {
			Default = "",
			LLD = "-fuse-ld=lld"
		},
		sanitize = {
			Address = "-fsanitize=address",
		},
		system = {
			wii = "$(MACHDEP)",
		},
		symbols = {
			Off = gcc.ldsymbols,
			Default = gcc.ldsymbols,
		}
	}

	function gcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, gcc.ldflags)
		return flags
	end



--
-- Return a list of decorated additional libraries directories.
--

	gcc.libraryDirectories = {
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

	function gcc.getLibraryDirectories(cfg)
		local flags = {}

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths. The call
		-- config.getlinks() all includes cfg.libdirs.
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(cfg.frameworkdirs) do
				dir = p.tools.getrelative(cfg.project, dir)
				table.insert(flags, '-F' .. p.quoted(dir))
			end
		end

		if cfg.flags.RelativeLinks then
			for _, dir in ipairs(config.getlinks(cfg, "siblings", "directory")) do
				local libFlag = "-L" .. p.tools.getrelative(cfg.project, dir)
				if not table.contains(flags, libFlag) then
					table.insert(flags, libFlag)
				end
			end
		end

		for _, dir in ipairs(cfg.syslibdirs) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		local gccFlags = config.mapFlags(cfg, gcc.libraryDirectories)
		flags = table.join(flags, gccFlags)

		return flags
	end



--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function gcc.getlinks(cfg, systemonly, nogroups)
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
				table.insert(result, "-framework")
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

	gcc.makesettings = {
		system = {
			wii = [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules']]
		}
	}

	function gcc.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, gcc.makesettings)
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

	gcc.tools = {
		cc = "gcc",
		cxx = "g++",
		ar = "ar",
		rc = "windres"
	}

	function gcc.gettoolname(cfg, tool)
		local toolset, version = p.tools.canonical(cfg.toolset or p.GCC)
		if toolset == p.tools.gcc and version ~= nil then
			version = "-" .. version
		else
			version = ""
		end
		return (cfg.gccprefix or "") .. gcc.tools[tool] .. version
	end
