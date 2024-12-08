--
-- snc.lua
-- Provides Sony SNC-specific configuration strings.
-- Copyright (c) 2010-2016 Jess Perkins and the Premake project
--

	local p = premake

	p.tools.snc = {}
	local snc = p.tools.snc
	local gcc = p.tools.gcc


--
-- Retrieve the CFLAGS for a specific configuration.
--

	snc.shared = {
		fatalwarnings = {
			Compile = "-Xquit=2",
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

	snc.cflags = {
	}

	function snc.getcflags(cfg)
		local shared = p.config.mapFlags(cfg, snc.shared)
		local cflags = p.config.mapFlags(cfg, snc.cflags)
		local flags = table.join(shared, cflags, snc.getwarnings(cfg))
		return flags
	end


--
-- Retrieve the CXXFLAGS for a specific configuration.
--

	snc.cxxflags = {
		exceptionhandling = {
			Default = "-Xc+=exceptions",
			On = "-Xc+=exceptions",
			SEH = "-Xc-=exceptions",
		},
		rtti = {
			Default = "-Xc+=rtti",
			On = "-Xc+=rtti",
			SEH = "-Xc-=rtti",
		}
	}

	function snc.getcxxflags(cfg)
		local shared = config.mapFlags(cfg, snc.shared)
		local cxxflags = config.mapFlags(cfg, snc.cxxflags)
		local flags = table.join(shared, cxxflags, snc.getwarnings(cfg))
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

		if not (cfg.symbols == p.ON) then
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
	snc.getrunpathdirs = gcc.getrunpathdirs
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
