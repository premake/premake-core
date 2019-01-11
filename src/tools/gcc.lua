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
			_ = { "-MMD", "-MP" }
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
			Extra = {"-Wall", "-Wextra"},
			High = "-Wall",
			Off = "-w",
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
		}
	}

	gcc.cflags = {
		cdialect = {
			["C89"] = "-std=c89",
			["C90"] = "-std=c90",
			["C99"] = "-std=c99",
			["C11"] = "-std=c11",
			["gnu89"] = "-std=gnu89",
			["gnu90"] = "-std=gnu90",
			["gnu99"] = "-std=gnu99",
			["gnu11"] = "-std=gnu11",
		}
	}

	function gcc.getcflags(cfg)
		local shared_flags = config.mapFlags(cfg, gcc.shared)
		local cflags = config.mapFlags(cfg, gcc.cflags)
		local flags = table.join(shared_flags, cflags)
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
			["gnu++98"] = "-std=gnu++98",
			["gnu++0x"] = "-std=gnu++0x",
			["gnu++11"] = "-std=gnu++11",
			["gnu++1y"] = "-std=gnu++1y",
			["gnu++14"] = "-std=gnu++14",
			["gnu++1z"] = "-std=gnu++1z",
			["gnu++17"] = "-std=gnu++17",
		},
		rtti = {
			Off = "-fno-rtti"
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

	function gcc.getcxxflags(cfg)
		local shared_flags = config.mapFlags(cfg, gcc.shared)
		local cxxflags = config.mapFlags(cfg, gcc.cxxflags)
		local flags = table.join(shared_flags, cxxflags)
		flags = table.join(flags, gcc.getwarnings(cfg))
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
			local fn = project.getrelative(cfg.project, value)
			table.insert(result, string.format('-include %s', p.quoted(fn)))
		end)

		return result
	end


--
-- Decorate include file search paths for the GCC command line.
--

	function gcc.getincludedirs(cfg, dirs, sysdirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end
		for _, dir in ipairs(sysdirs or {}) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-isystem ' .. p.quoted(dir))
		end
		return result
	end

--
-- Return a list of decorated rpaths
--

	function gcc.getrunpathdirs(cfg, dirs)
		local result = {}

		if not (table.contains(os.getSystemTags(cfg.system), "darwin")
				or (cfg.system == p.LINUX)) then
			return result
		end

		local rpaths = {}

		-- User defined runpath search paths
		for _, fullpath in ipairs(cfg.runpathdirs) do
			local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
			if not (table.contains(rpaths, rpath)) then
				table.insert(rpaths, rpath)
			end
		end

		-- Automatically add linked shared libraries path relative to target directory
		for _, sibling in ipairs(config.getlinks(cfg, "siblings", "object")) do
			if (sibling.kind == p.SHAREDLIB) then
				local fullpath = sibling.linktarget.directory
				local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
				if not (table.contains(rpaths, rpath)) then
					table.insert(rpaths, rpath)
				end
			end
		end

		for _, rpath in ipairs(rpaths) do
			if table.contains(os.getSystemTags(cfg.system), "darwin") then
				rpath = "@loader_path/" .. rpath
			elseif (cfg.system == p.LINUX) then
				rpath = iif(rpath == ".", "", "/" .. rpath)
				rpath = "$$ORIGIN" .. rpath
			end

			table.insert(result, "-Wl,-rpath,'" .. rpath .. "'")
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

		if not nogroups and #result > 1 and (cfg.linkgroups == p.ON) then
			table.insert(result, 1, "-Wl,--start-group")
			table.insert(result, "-Wl,--end-group")
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
		if (cfg.gccprefix and gcc.tools[tool]) or tool == "rc" then
			return (cfg.gccprefix or "") .. gcc.tools[tool]
		end
		return nil
	end
