--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.tools.gcc = {}
	local gcc = premake.tools.gcc
	local project = premake5.project
	local config = premake5.config
	

--
-- GCC flags for specific systems and architectures.
--

	gcc.sysflags = {
		haiku = {
			cppflags = "-MMD"
		},
		
		x32 = {
			cflags  = "-m32",
			ldflags = { "-m32", "-L/usr/lib32" }
		},

		x64 = {
			cflags = "-m64",
			ldflags = { "-m64", "-L/usr/lib64" }
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
			ldflags	= "-L$(LIBOGC_LIB) $(MACHDEP)",
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

		for _, fi in ipairs(cfg.forceincludes) do
			local fn = project.getrelative(cfg.project, fi)
			table.insert(flags, string.format('-include "%s"', fn))
		end
		
		return flags
	end

--
-- Returns list of C compiler flags for a configuration.
--

	gcc.cflags = {
		EnableSSE      = "-msse",
		EnableSSE2     = "-msse2",
		ExtraWarnings  = "-Wall -Wextra",
		FatalWarnings  = "-Werror",
		FloatFast      = "-ffast-math",
		FloatStrict    = "-ffloat-store",
		NoFramePointer = "-fomit-frame-pointer",
		Optimize       = "-O2",
		OptimizeSize   = "-Os",
		OptimizeSpeed  = "-O3",
		Symbols        = "-g",
	}
	
	function gcc.getcflags(cfg)
		local flags = table.translate(cfg.flags, gcc.cflags)

		local sysflags = gcc.getsysflags(cfg, 'cflags')
		flags = table.join(flags, sysflags)

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
-- Decorate include file search paths for the GCC command line.
--

	function gcc.getincludedirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			table.insert(result, "-I" .. project.getrelative(cfg.project, dir))
		end
		return result
	end


--
-- Return a list of LDFLAGS for a specific configuration.
--

	function gcc.getldflags(cfg)
		local flags = {}
		
		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "all", "directory")) do
			table.insert(flags, '-L' .. dir)
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
		
		local sysflags = gcc.getsysflags(cfg, 'ldflags')
		flags = table.join(flags, sysflags)
		
		return flags
	end


--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function gcc.getlinks(cfg, systemonly)
		local result = {}
		
		local links
		if not systemonly then
			links = config.getlinks(cfg, "siblings", "object")
			for _, link in ipairs(links) do
				-- skip external project references, since I have no way
				-- to know the actual output target path
				if not link.project.external then
					if link.kind == premake.STATICLIB then
						-- Don't use "-l" flag when linking static libraries; instead use 
						-- path/libname.a to avoid linking a shared library of the same
						-- name if one is present
						table.insert(result, project.getrelative(cfg.project, link.linktarget.abspath))
					else
						table.insert(result, "-l" .. link.linktarget.basename)
					end
				end
			end
		end
				
		-- The "-l" flag is fine for system libraries
		links = config.getlinks(cfg, "system", "basename")
		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework " .. path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				table.insert(result, "-l" .. link)
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

