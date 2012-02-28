--
-- snc.lua
-- Provides Sony SNC-specific configuration strings.
-- Copyright (c) 2010-2012 Jason Perkins and the Premake project
--

	premake.tools.snc = {}
	local snc = premake.tools.snc
	local config = premake5.config
	

--
-- SNC flags for specific systems and architectures.
--

	snc.sysflags = {
	}


--
-- Retrieve the CPPFLAGS for a specific configuration.
--

	function snc.getcppflags(cfg)
		return { "-MMD", "-MP" }
	end


--
-- Retrieve the CFLAGS for a specific configuration.
--

	snc.cflags = {
		ExtraWarnings  = "-Xdiag=2",
		FatalWarnings  = "-Xquit=2",
	}

	function snc.getcflags(cfg)
		local flags = table.translate(cfg.flags, snc.cflags)
		return flags
	end


--
-- Retrieve the CXXFLAGS for a specific configuration.
--

	snc.cxxflags = {
		NoExceptions   = "-Xc-=exceptions",
		NoRTTI         = "-Xc-=rtti",
	}

	function snc.getcxxflags(cfg)
		local flags = table.translate(cfg.flags, snc.cxxflags)
		
		-- turn on exceptions and RTTI by default, to match other toolsets
		if not cfg.flags.NoExceptions then
			table.insert(flags, "-Xc+=exceptions")
		end
		if not cfg.flags.NoRTTI then
			table.insert(flags, "-Xc+=rtti")
		end
		
		return flags
	end


--
-- Retrieve the LDFLAGS for a specific configuration.
--

	function snc.getldflags(cfg)
		local flags = { }
		
		if not cfg.flags.Symbols then
			table.insert(flags, "-s")
		end
		
		return flags
	end


--
-- The linking behavior is the same as GCC.
--

	snc.getlinks = premake.tools.gcc.getlinks



-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------
	
	premake.snc = { }


-- TODO: Will cfg.system == "windows" ever be true for SNC? If
-- not, remove the conditional blocks that use this test.

--
-- Set default tools
--

	premake.snc.cc     = "snc"
	premake.snc.cxx    = "g++"
	premake.snc.ar     = "ar"
	
	
--
-- Translation of Premake flags into SNC flags
--

	local cflags =
	{
		ExtraWarnings  = "-Xdiag=2",
		FatalWarnings  = "-Xquit=2",
	}

	local cxxflags =
	{
		NoExceptions   = "", -- No exceptions is the default in the SNC compiler.
		NoRTTI         = "-Xc-=rtti",
	}
	
	
--
-- Map platforms to flags
--

	premake.snc.platforms = 
	{
		PS3 = {
			cc         = "ppu-lv2-g++",
			cxx        = "ppu-lv2-g++",
			ar         = "ppu-lv2-ar",
			cppflags   = "-MMD -MP",
		}
	}

	local platforms = premake.snc.platforms
	

--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function premake.snc.getcppflags(cfg)
		local result = { }
		table.insert(result, platforms[cfg.platform].cppflags)
		return result
	end

	function premake.snc.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		table.insert(result, platforms["PS3"].flags)
		if cfg.kind == "SharedLib" then
			table.insert(result, "-fPIC")
		end
		
		return result		
	end
	
	function premake.snc.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end
	


--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function premake.snc.getldflags(cfg)
		local result = { }
		
		if not cfg.flags.Symbols then
			table.insert(result, "-s")
		end
	
		if cfg.kind == "SharedLib" then
			table.insert(result, "-shared")				
			if not cfg.flags.NoImportLib then
				table.insert(result, '-Wl,--out-implib="' .. cfg.linktarget.fullpath .. '"')
			end
		end
		
		local platform = platforms["PS3"]
		table.insert(result, platform.flags)
		table.insert(result, platform.ldflags)
		
		return result
	end
		

--
-- Return a list of library search paths. Technically part of LDFLAGS but need to
-- be separated because of the way Visual Studio calls SNC for the PS3. See bug 
-- #1729227 for background on why library paths must be split.
--

	function premake.snc.getlibdirflags(cfg)
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

	function premake.snc.getlinkflags(cfg)
		local result = { }
		for _, value in ipairs(premake.getlinks(cfg, "all", "basename")) do
			table.insert(result, '-l' .. _MAKE.esc(value))
		end
		return result
	end
	
	

--
-- Decorate defines for the SNC command line.
--

	function premake.snc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end


	
--
-- Decorate include file search paths for the SNC command line.
--

	function premake.snc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, "-I" .. _MAKE.esc(dir))
		end
		return result
	end
