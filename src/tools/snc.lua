--
-- snc.lua
-- Provides Sony SNC-specific configuration strings.
-- Copyright (c) 2010-2012 Jason Perkins and the Premake project
--

	premake.tools.snc = {}
	local snc = premake.tools.snc
	local gcc = premake.tools.gcc
	local config = premake.config


--
-- Retrieve the CFLAGS for a specific configuration.
--

	snc.cflags = {
		flags = {
			FatalCompileWarnings = "-Xquit=2",
		},
		optimize = {
			Off = "-O0",
			On = "-O1",
			Debug = "-Od",
			Full = "-O3",
			Size = "-Os",
			Speed = "-O2",
			},
		warnings = {
			Extra = "-Xdiag=2",
		}
	}

	function snc.getcflags(cfg)
		local flags = config.mapFlags(cfg, snc.cflags)
		return flags
	end


--
-- Retrieve the CXXFLAGS for a specific configuration.
--

	function snc.getcxxflags(cfg)
		local flags = {}

		-- turn on exceptions and RTTI by default, to match other toolsets
		if cfg.exceptionhandling == p.ON then
			table.insert(flags, "-Xc+=exceptions")
		elseif cfg.exceptionhandling == p.OFF then
			table.insert(flags, "-Xc-=exceptions")
		end

		if cfg.rtti == p.ON then
			table.insert(flags, "-Xc+=rtti")
		elseif cfg.rtti == p.OFF then
			table.insert(flags, "-Xc-=rtti")
		end

		return flags
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

	function snc.getforceincludes(cfg)

		-- Just pass through to GCC for now
		local flags = gcc.getforceincludes(cfg)
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
-- These are the same as GCC
--

	snc.getcppflags = gcc.getcppflags
	snc.getdefines = gcc.getdefines
	snc.getincludedirs = gcc.getincludedirs
	snc.getLibraryDirectories = gcc.getLibraryDirectories
	snc.getlinks = gcc.getlinks


--
-- Returns makefile-specific configuration rules.
--

	function snc.getmakesettings(cfg)
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

	snc.tools = {
	}

	function snc.gettoolname(cfg, tool)
		local names = snc.tools[cfg.architecture] or snc.tools[cfg.system] or {}
		return names[tool]
	end
