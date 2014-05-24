--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	premake.tools.gcc = {}
	local gcc = premake.tools.gcc
	local project = premake.project
	local config = premake.config


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
-- Returns list of C compiler flags for a configuration.
--

	gcc.cflags = {
		architecture = {
			x32 = "-m32",
			x64 = "-m64",
		},
		flags = {
			FatalCompileWarnings = "-Werror",
			NoFramePointer = "-fomit-frame-pointer",
			Symbols = "-g"
		},
		floatingpoint = {
			Fast = "-ffast-math",
			Strict = "-ffloat-store",
		},
		kind = {
			SharedLib = function(cfg)
				if cfg.system ~= premake.WINDOWS then return "-fPIC" end
			end,
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Debug = "-Og",
			Full = "-O3",
			Size = "-Os",
			Speed = "-O3",
		},
		vectorextensions = {
			AVX = "-mavx",
			SSE = "-msse",
			SSE2 = "-msse2",
		},
		warnings = {
			Extra = "-Wall -Wextra",
			Off = "-w",
		}
	}

	function gcc.getcflags(cfg)
		local flags = config.mapFlags(cfg, gcc.cflags)
		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	gcc.cxxflags = {
		flags = {
			NoExceptions = "-fno-exceptions",
			NoRTTI = "-fno-rtti",
			NoBufferSecurityCheck = "-fno-stack-protector"
		}
	}

	function gcc.getcxxflags(cfg)
		local flags = config.mapFlags(cfg, gcc.cxxflags)
		return flags
	end


--
-- Decorate defines for the GCC command line.
--

	function gcc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. define)
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
			table.insert(result, string.format('-include %s', premake.quoted(fn)))
		end)

		return result
	end


--
-- Decorate include file search paths for the GCC command line.
--

	function gcc.getincludedirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. premake.quoted(dir))
		end
		return result
	end


--
-- Return a list of LDFLAGS for a specific configuration.
--

	gcc.ldflags = {
		architecture = {
			x32 = "-m32",
			x64 = "-m64",
		},
		flags = {
			_Symbols = function(cfg)
				-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
				return iif(cfg.system == premake.MACOSX, "-Wl,-x", "-s")
			end,
		},
		kind = {
			SharedLib = function(cfg)
				local r = { iif(cfg.system == premake.MACOSX, "-dynamiclib", "-shared") }
				if cfg.system == "windows" and not cfg.flags.NoImportLib then
					table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
				end
				return r
			end,
			WindowedApp = function(cfg)
				if cfg.system == premake.WINDOWS then return "-mwindows" end
			end,
		},
		system = {
			wii = "$(MACHDEP)",
		}
	}

	function gcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, gcc.ldflags)
		flags = table.join(flags, cfg.linkoptions)
		return flags
	end



--
-- Return a list of decorated additional libraries directories.
--

	gcc.libraryDirectories = {
		architecture = {
			x32 = "-L/usr/lib32",
			x64 = "-L/usr/lib64",
		},
		system = {
			wii = "-L$(LIBOGC_LIB)",
		}
	}

	function gcc.getLibraryDirectories(cfg)
		local flags = config.mapFlags(cfg, gcc.libraryDirectories)

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. project.getrelative(cfg.project, dir))
		end

		return flags
	end



--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function gcc.getlinks(cfg, systemonly)
		local result = {}

		-- Don't use the -l form for sibling libraries, since they may have
		-- custom prefixes or extensions that will confuse the linker. Instead
		-- just list out the full relative path to the library.

		if not systemonly then
			result = config.getlinks(cfg, "siblings", "fullpath")
		end

		-- The "-l" flag is fine for system libraries

		local links = config.getlinks(cfg, "system", "fullpath")
		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework " .. path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				table.insert(result, "-l" .. path.getbasename(link))
			end
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
		ps3 = {
			cc = "ppu-lv2-g++",
			cxx = "ppu-lv2-g++",
			ar = "ppu-lv2-ar",
		},
	}

	function gcc.gettoolname(cfg, tool)
		local names = gcc.tools[cfg.architecture] or gcc.tools[cfg.system] or {}
		local name = names[tool]

		if tool == "rc" then
			name = name or "windres"
		end

		return name
	end

