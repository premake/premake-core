--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--

	premake.tools.gcc = {}
	local gcc = premake.tools.gcc
	local project = premake.project
	local config = premake.config


--
-- GCC flags for specific systems and architectures.
--

	gcc.sysflags = {
		haiku = {
			cppflags = "-MMD"
		},

		ps3 = {
			cc = "ppu-lv2-g++",
			cxx = "ppu-lv2-g++",
			ar = "ppu-lv2-ar",
		},

		universal = {
			cppflags = "",  -- block default -MMD -MP flags
		},

		wii = {
			cppflags = "-MMD -MP -I$(LIBOGC_INC) $(MACHDEP)",
			cfgsettings = [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules']],
		},
	}



	function gcc.getsysflags(cfg, field)
		local result = {}

		-- merge in system-level flags
		local system = gcc.sysflags[cfg.system]
		if system then
			result = table.join(result, system[field])
		end

		-- merge in architecture-level flags
		local arch = gcc.sysflags[cfg.architecture]
		if arch then
			result = table.join(result, arch[field])
		end

		return result
	end



--
-- Returns list of C preprocessor flags for a configuration.
--

	function gcc.getcppflags(cfg)
		local flags = gcc.getsysflags(cfg, 'cppflags')

		-- Use -MMD -P by default to generate dependency information
		if #flags == 0 then
			flags = { "-MMD", "-MP" }
		end

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
			FatalWarnings = "-Werror",
			NoFramePointer = "-fomit-frame-pointer",
			Symbols = "-g"
		},
		floatingpoint = {
			Fast = "-ffast-math",
			Strict = "-ffloat-store",
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Size = "-Os",
			Speed = "-O3",
		},
		vectorextensions = {
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

		-- TODO: Would love to see this as a configuration
		--   configuration { "SharedLib", "not Windows" }
		--       flags { "PIC" }

		if cfg.system ~= premake.WINDOWS and cfg.kind == premake.SHAREDLIB then
			table.insert(flags, "-fPIC")
		end

		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	gcc.cxxflags = {
		NoExceptions   = "-fno-exceptions",
		NoRTTI         = "-fno-rtti",
		NoBufferSecurityCheck = "-fno-stack-protector"
	}

	function gcc.getcxxflags(cfg)
		local flags = table.translate(cfg.flags, gcc.cxxflags)
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
			x32 = { "-m32", "-L/usr/lib32" },
			x64 = { "-m64", "-L/usr/lib64" },
		},
		system = {
			wii = { "-L$(LIBOGC_LIB)", "$(MACHDEP)" },
		}
	}

	function gcc.getldflags(cfg)
		local flags = {}

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. project.getrelative(cfg.project, dir))
		end

		if not cfg.flags.Symbols then
			-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
			if cfg.system == premake.MACOSX then
				table.insert(flags, "-Wl,-x")
			else
				table.insert(flags, "-s")
			end
		end

		if cfg.kind == premake.SHAREDLIB then
			if cfg.system == premake.MACOSX then
				table.insert(flags, "-dynamiclib")
			else
				table.insert(flags, "-shared")
			end

			if cfg.system == "windows" and not cfg.flags.NoImportLib then
				table.insert(flags, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
			end
		end

		if cfg.kind == premake.WINDOWEDAPP and cfg.system == premake.WINDOWS then
			table.insert(flags, "-mwindows")
		end

		return table.join(flags, config.mapFlags(cfg, gcc.ldflags))
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

	function gcc.getmakesettings(cfg)
		local sysflags = gcc.sysflags[cfg.architecture] or gcc.sysflags[cfg.system] or {}
		return sysflags.cfgsettings
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

	function gcc.gettoolname(cfg, tool)
		local sysflags = gcc.sysflags[cfg.architecture] or gcc.sysflags[cfg.system] or {}
		return sysflags[tool]
	end

