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
-- SNC flags for specific systems and architectures.
--

	snc.sysflags = {}


--
-- Retrieve the CFLAGS for a specific configuration.
--

	snc.cflags = {
		flags = {
			FatalWarnings = "-Xquit=2",
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

	function snc.gettoolname(cfg, tool)
		local sysflags = snc.sysflags[cfg.architecture] or snc.sysflags[cfg.system] or {}
		return sysflags[tool]
	end

