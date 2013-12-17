--
-- msc.lua
-- Interface for the MS C/C++ compiler.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--


	premake.tools.msc = {}
	local msc = premake.tools.msc
	local project = premake.project
	local config = premake.config


--
-- Returns list of C preprocessor flags for a configuration.
--

	function msc.getcppflags(cfg)
		return {}
	end


--
-- Returns list of C compiler flags for a configuration.
--

	msc.cflags = {
		flags = {
			FatalWarnings = "/WX",
			MultiProcessorCompile = "/MP",
			NoFramePointer = "/Oy",
			NoMinimalRebuild = "/Gm-",
			SEH = "/EHa",
			Symbols = "/Z7",
			OmitDefaultLibrary = "/Zl",
		},
		floatingpoint = {
			Fast = "/fp:fast",
			Strict = "/fp:strict",
		},
		optimize = {
			Off = "/Od",
			On = "/Ot",
			Debug = "/Od",
			Full = "/Ox",
			Size = "/O1",
			Speed = "/O2",
		},
		vectorextensions = {
			SSE = "/arch:sse",
			SSE2 = "/arch:sse2",
		},
		warnings = {
			Extra = "/W4",
			Off = "/W0",
		}
	}

	function msc.getcflags(cfg)
		local flags = config.mapFlags(cfg, msc.cflags)

		local runtime = iif(cfg.flags.StaticRuntime, "/MT", "/MD")
		if config.isDebugBuild(cfg) then
			runtime = runtime .. "d"
		end
		table.insert(flags, runtime)

		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	msc.cxxflags = {
		flags = {
			NoRTTI = "/GR-",
		}
	}

	function msc.getcxxflags(cfg)
		local flags = config.mapFlags(cfg, msc.cxxflags)

		if not cfg.flags.SEH and not cfg.flags.NoExceptions then
			table.insert(flags, "/EHsc")
		end

		return flags
	end


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
-- Returns a list of forced include files, decorated for the compiler
-- command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of force include files with the appropriate flags.
--

	function msc.getforceincludes(cfg)
		local result = {}

		table.foreachi(cfg.forceincludes, function(value)
			local fn = project.getrelative(cfg.project, value)
			table.insert(result, "/FI" .. premake.quoted(fn))
		end)

		return result
	end



--
-- Decorate include file search paths for the MSVC command line.
--

	function msc.getincludedirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' ..  premake.quoted(dir))
		end
		return result
	end


--
-- Return a list of linker flags for a specific configuration.
--

	msc.linkerFlags = {
		flags = {
			FatalWarnings = "/WX",
			LinkTimeOptimization = "/GL",
			NoIncrementalLink = "/INCREMENTAL:NO",
			_NoIncrementalLink = "/INCREMENTAL",
			NoManifest = "/MANIFEST:NO",
			_NoManifest = "/MANIFEST",
			OmitDefaultLibrary = "/NODEFAULTLIB",
			Symbols = "/DEBUG",
		}
	}

	msc.librarianFlags = {
		flags = {
			FatalWarnings = "/WX",
			Symbols = "/DEBUG",
		}
	}

	function msc.getldflags(cfg)
		local map = iif(cfg.kind ~= premake.STATICLIB, msc.linkerFlags, msc.librarianFlags)
		local flags = config.mapFlags(cfg, map)
		table.insert(flags, 1, "/NOLOGO")

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
