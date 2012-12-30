--
-- msc.lua
-- Interface for the MS C/C++ compiler.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	
	premake.tools.msc = {}
	local msc = premake.tools.msc
	local project = premake5.project
	local config = premake5.config


--
-- Returns list of C preprocessor flags for a configuration.
--

	function msc.getcppflags(cfg)
		local flags = {}

		for _, fi in ipairs(cfg.forceincludes) do
			local fn = project.getrelative(cfg.project, fi)
			table.insert(flags, string.format('/FI "%s"', fn))
		end

		return flags		
	end


--
-- Returns list of C compiler flags for a configuration.
--

	msc.cflags = {
		SEH           = "/EHa",
		OptimizeSpeed = "/O2",
	}
	
	function msc.getcflags(cfg)
		local flags = table.translate(cfg.flags, msc.cflags)

		local runtime = iif(cfg.flags.StaticRuntime, "/MT", "/MD")
		if premake.config.isdebugbuild(cfg) then
			runtime = runtime .. "d"
		end
		table.insert(flags, runtime)
		
		if not premake.config.isoptimizedbuild(cfg) then
			table.insert(flags, "/Od")
		end
		
		if cfg.flags.Symbols then
			table.insert(flags, "/Z7")
		end

		if not cfg.flags.SEH then
			table.insert(flags, "/EHsc")
		end
				
		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	msc.cxxflags = {
	}
	
	function msc.getcxxflags(cfg)
		return table.translate(cfg.flags, msc.cxxflags)
	end

	msc.ldflags = {
		Symbols = "/DEBUG",
	}
	

--
-- Decorate defines for the MSVC command line.
--

	function msc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. define)
		end
		return result
	end


--
-- Decorate include file search paths for the MSVC command line.
--

	function msc.getincludedirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			table.insert(result, "-I" .. project.getrelative(cfg.project, dir))
		end
		return result
	end


--
-- Return a list of linker flags for a specific configuration.
--
	msc.ldflags = {
		Symbols = "/DEBUG",
	}

	function msc.getldflags(cfg)
		local flags = table.translate(cfg.flags, msc.ldflags)

		if not cfg.flags.NoManifest and cfg.kind ~= premake.STATICLIB then
			table.insert(flags, "/MANIFEST")
		end
		
		if premake.config.isoptimizedbuild(cfg) then
			table.insert(flags, "/OPT:REF /OPT:ICF")
		end
		
		for _, libdir in ipairs(project.getrelative(cfg.project, cfg.libdirs)) do
			table.insert(flags, '/LIBPATH:"' .. libdir .. '"')
		end
		
		return flags
	end


--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function msc.getlinks(cfg)
		local links = config.getlinks(cfg, "system", "fullpath")
		return links
	end


--
-- Returns makefile-specific configuration rules.
--

	function msc.getmakesettings(cfg)
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

	function msc.gettoolname(cfg, tool)
		return nil
	end
