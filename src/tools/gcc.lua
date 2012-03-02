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
		x32 = {
			cflags  = "-m32",
			ldflags = { "-m32", "-L/usr/lib32" }
		},

		x64 = {
			cflags = "-m64",
			ldflags = { "-m64", "-L/usr/lib64" }
		}
	}


--
-- Returns list of CPPFLAGS for a specific configuration.
--

	function gcc.getcppflags(cfg)
		-- always use -MMD to generate dependency information
		local flags = { "-MMD" }
		
		-- We want the -MP flag for dependency generation (creates phony rules 
		-- for headers, prevents make errors if file is later deleted), but Haiku 
		-- OS doesn't support it (yet)
		if cfg.system ~= premake.HAIKU then
			table.insert(flags, "-MP")
		end
		
		return flags
	end

--
-- Returns list of CFLAGS for a specific configuration.
--

	gcc.cflags = {
		EnableSSE      = "-msse",
		EnableSSE2     = "-msse2",
		ExtraWarnings  = "-Wall",
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

		local sysflags = gcc.sysflags[cfg.architecture] or {}
		flags = table.join(flags, sysflags.cflags)

		if cfg.system ~= premake.WINDOWS and cfg.kind == premake.SHAREDLIB then
			table.insert(flags, "-fPIC")
		end

		return flags
	end


--
-- Returns a list of CXXFLAGS for a specific configuration.
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
-- Return a list of LDFLAGS for a specific configuration.
--

	function gcc.getldflags(cfg)
		local flags = {}
		
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
				flags = table.join(flags, { "-dynamiclib", "-flat_namespace" })
			else
				table.insert(flags, "-shared")
			end

			if cfg.system == "windows" and not cfg.flags.NoImportLib then
				table.insert(flags, '-Wl,--out-implib="' .. config.getlinkinfo(cfg).fullpath .. '"')
			end
		end
	
		if cfg.kind == premake.WINDOWEDAPP and cfg.system == premake.WINDOWS then
			table.insert(flags, "-mwindows")
		end
		
		local sysflags = gcc.sysflags[cfg.architecture] or {}
		flags = table.join(flags, sysflags.ldflags)
		
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
				if link.kind == premake.STATICLIB then
					-- Don't use "-l" flag when linking static libraries; instead use 
					-- path/libname.a to avoid linking a shared library of the same
					-- name if one is present
					local linkinfo = config.getlinkinfo(link)
					table.insert(result, project.getrelative(cfg.project, linkinfo.abspath))
				else
					table.insert(result, "-l" .. link.basename)
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


-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------
	
	premake.gcc = { }
	

--
-- Set default tools
--

	premake.gcc.cc     = "gcc"
	premake.gcc.cxx    = "g++"
	premake.gcc.ar     = "ar"
	
	
--
-- Translation of Premake flags into GCC flags
--

	local cflags =
	{
		EnableSSE      = "-msse",
		EnableSSE2     = "-msse2",
		ExtraWarnings  = "-Wall",
		FatalWarnings  = "-Werror",
		FloatFast      = "-ffast-math",
		FloatStrict    = "-ffloat-store",
		NoFramePointer = "-fomit-frame-pointer",
		Optimize       = "-O2",
		OptimizeSize   = "-Os",
		OptimizeSpeed  = "-O3",
		Symbols        = "-g",
	}

	local cxxflags =
	{
		NoExceptions   = "-fno-exceptions",
		NoRTTI         = "-fno-rtti",
	}
	
	
--
-- Map platforms to flags
--

	premake.gcc.platforms = 
	{
		Native = { 
			cppflags = "-MMD",
		},
		x32 = { 
			cppflags = "-MMD",	
			flags    = "-m32",
			ldflags  = "-L/usr/lib32", 
		},
		x64 = { 
			cppflags = "-MMD",
			flags    = "-m64",
			ldflags  = "-L/usr/lib64",
		},
		Universal = { 
			cppflags = "",
			flags    = "-arch i386 -arch x86_64 -arch ppc -arch ppc64",
		},
		Universal32 = { 
			cppflags = "",
			flags    = "-arch i386 -arch ppc",
		},
		Universal64 = { 
			cppflags = "",
			flags    = "-arch x86_64 -arch ppc64",
		},
		PS3 = {
			cc         = "ppu-lv2-g++",
			cxx        = "ppu-lv2-g++",
			ar         = "ppu-lv2-ar",
			cppflags   = "-MMD",
		},
		WiiDev = {
			cppflags    = "-MMD -MP -I$(LIBOGC_INC) $(MACHDEP)",
			ldflags		= "-L$(LIBOGC_LIB) $(MACHDEP)",
			cfgsettings = [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules']],
		},
	}

	local platforms = premake.gcc.platforms
	

--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function premake.gcc.getcppflags(cfg)
		local flags = { }
		table.insert(flags, platforms[cfg.platform].cppflags)

		-- We want the -MP flag for dependency generation (creates phony rules
		-- for headers, prevents make errors if file is later deleted), but 
		-- Haiku doesn't support it (yet)
		if flags[1]:startswith("-MMD") and cfg.system ~= "haiku" then
			table.insert(flags, "-MP")
		end

		return flags
	end


	function premake.gcc.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		table.insert(result, platforms[cfg.platform].flags)
		if cfg.system ~= "windows" and cfg.kind == "SharedLib" then
			table.insert(result, "-fPIC")
		end
		return result		
	end
	

	function premake.gcc.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end

	
--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function premake.gcc.getldflags(cfg)
		local result = { }
		
		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		if not cfg.flags.Symbols then
			if cfg.system == "macosx" then
				table.insert(result, "-Wl,-x")
			else
				table.insert(result, "-s")
			end
		end
	
		if cfg.kind == "SharedLib" then
			if cfg.system == "macosx" then
				result = table.join(result, { "-dynamiclib", "-flat_namespace" })
			else
				table.insert(result, "-shared")
			end
				
			if cfg.system == "windows" and not cfg.flags.NoImportLib then
				table.insert(result, '-Wl,--out-implib="' .. cfg.linktarget.fullpath .. '"')
			end
		end

		if cfg.kind == "WindowedApp" and cfg.system == "windows" then
			table.insert(result, "-mwindows")
		end
		
		local platform = platforms[cfg.platform]
		table.insert(result, platform.flags)
		table.insert(result, platform.ldflags)
		
		return result
	end
		

--
-- Return a list of library search paths. Technically part of LDFLAGS but need to
-- be separated because of the way Visual Studio calls GCC for the PS3. See bug 
-- #1729227 for background on why library paths must be split.
--

	function premake.gcc.getlibdirflags(cfg)
		local result = { }
		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L' .. _MAKE.esc(value))
		end
		return result
	end
	


--
-- Returns a list of linker flags for library search directories and library
-- names. See bug #1729227 for background on why the path must be split.
--

	function premake.gcc.getlinkflags(cfg)
		local result = { }

		for _, value in ipairs(premake.getlinks(cfg, "siblings", "object")) do
			if (value.kind == "StaticLib") then
				-- don't use "-lname" when linking static libraries
				-- instead use path/Name.ext so as not to link with a SharedLib of the same name
				-- if one is present.
				local pathstyle = premake.getpathstyle(value)
				local namestyle = premake.getnamestyle(value)
				local linktarget = premake.gettarget(value, "link",  pathstyle, namestyle, cfg.system)
				local rebasedpath = path.rebase(linktarget.fullpath, value.location, cfg.location)
				table.insert(result, rebasedpath)
			else
				--premake does not support creating frameworks so this is just a SharedLib link
				--link using -lname
				table.insert(result, '-l' .. _MAKE.esc(value.linktarget.basename))
			end
		end

		-- "-llib" is fine for system dependencies
		for _, value in ipairs(premake.getlinks(cfg, "system", "basename")) do
			if path.getextension(value) == ".framework" then
				table.insert(result, '-framework ' .. _MAKE.esc(path.getbasename(value)))
			else
				table.insert(result, '-l' .. _MAKE.esc(value))
			end
		end
		return result
	end
	
	

--
-- Decorate defines for the GCC command line.
--

	function premake.gcc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end


	
--
-- Decorate include file search paths for the GCC command line.
--

	function premake.gcc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, "-I" .. _MAKE.esc(dir))
		end
		return result
	end


-- 
-- Return platform specific project and configuration level
-- makesettings blocks.
--	

	function premake.gcc.getcfgsettings(cfg)
		return platforms[cfg.platform].cfgsettings
	end
