--
-- ow.lua
-- Provides Open Watcom-specific configuration strings.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	premake.ow = { }
	local ow = premake.ow

	premake.ow.namestyle = "windows"

	
--
-- Set default tools
--

	ow.cc     = "WCL386"
	ow.cxx    = "WCL386"
	ow.ar     = "ar"
	
	
--
-- Translation of Premake flags into OpenWatcom flags
--

	local cflags =
	{
		ExtraWarnings  = "-wx",
		FatalWarning   = "-we",
		FloatFast      = "-omn",
		FloatStrict    = "-op",
		Optimize       = "-ox",
		OptimizeSize   = "-os",
		OptimizeSpeed  = "-ot",
		Symbols        = "-d2",
	}

	local cxxflags =
	{
		NoExceptions   = "-xd",
		NoRTTI         = "-xr",
	}
	


--
-- No specific platform support yet
--

	ow.platforms = 
	{
		Native = { 
			flags = "" 
		},
	}


	
--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function ow.getcppflags(cfg)
		return {}
	end

	function ow.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)		
		if (cfg.flags.Symbols) then
			table.insert(result, "-hw")   -- Watcom debug format for Watcom debugger
		end
		return result		
	end
	
	function ow.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end
	


--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function ow.getldflags(cfg)
		local result = { }
		
		if (cfg.flags.Symbols) then
			table.insert(result, "op symf")
		end
				
		return result
	end
		
	
--
-- Returns a list of linker flags for library search directories and 
-- library names.
--

	function ow.getlinkflags(cfg)
		local result = { }
		return result
	end
	
	

--
-- Decorate defines for the command line.
--

	function ow.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end


	
--
-- Decorate include file search paths for the command line.
--

	function ow.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, '-I "' .. dir .. '"')
		end
		return result
	end


--
-- Returns makefile-specific configuration rules.
--

	function ow.getmakesettings(cfg)
		return nil
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

	function ow.gettoolname(cfg, tool)
		return ow[tool]
	end

