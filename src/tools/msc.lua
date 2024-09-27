---
-- msc.lua
-- Interface for the MS C/C++ compiler.
-- Author Jason Perkins
-- Modified by Manu Evans
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---


	local p = premake

	p.tools.msc = {}
	local msc = p.tools.msc
	local project = p.project
	local config = p.config
	local string = require("string")

	-- string comparison `toolset >= "msc-v142"` won't work with "msc-v80"
	local function isVersionGreaterOrEqualTo(lhs, rhs)
		if lhs == nil or rhs == nil then
			return false
		end
		lhs = _G.tonumber(string.match(lhs, "^msc%-v([0-9]+)$"))
		rhs = _G.tonumber(string.match(rhs, "^msc%-v([0-9]+)$"))
		if lhs == nil or rhs == nil then
			return false
		end
		return lhs >= rhs
	end

--
-- Returns list of C preprocessor flags for a configuration.
--

	function msc.getcppflags(cfg)
		return {}
	end


--
-- Returns list of C compiler flags for a configuration.
--

	local function getRuntimeFlag(cfg, isstatic)
		local rt = cfg.runtime
		local flag = iif(isstatic, "/MT", "/MD")
		if (rt == "Debug") or (rt == nil and config.isDebugBuild(cfg))  then
			flag = flag .. "d"
		end
		return flag
	end

	msc.shared = {
		clr = {
			On = "/clr",
			Unsafe = "/clr",
			Pure = "/clr:pure",
			Safe = "/clr:safe",
		},
		compileas = {
			["C"] = "/TC",
			["C++"] = "/TP",
		},
		flags = {
			FatalCompileWarnings = "/WX",
			LinkTimeOptimization = "/GL",
			MultiProcessorCompile = "/MP",
			NoMinimalRebuild = "/Gm-",
			OmitDefaultLibrary = "/Zl"
		},
		floatingpoint = {
			Fast = "/fp:fast",
			Strict = "/fp:strict",
		},
		floatingpointexceptions = {
			On  = "/fp:except",
			Off = "/fp:except-",
		},
		functionlevellinking = {
			On = "/Gy",
			Off = "/Gy-",
		},
		callingconvention = {
			Cdecl = "/Gd",
			FastCall = "/Gr",
			StdCall = "/Gz",
			VectorCall = "/Gv",
		},
		intrinsics = {
			On = "/Oi",
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
			AVX = "/arch:AVX",
			AVX2 = "/arch:AVX2",
			SSE = "/arch:SSE",
			SSE2 = "/arch:SSE2",
			SSE3 = "/arch:SSE2",
			SSSE3 = "/arch:SSE2",
			["SSE4.1"] = "/arch:SSE2",
			["SSE4.2"] = "/arch:SSE2",
		},
		warnings = {
			Off = "/W0",
			High = "/W4",
			Extra = "/W4",
			Everything = "/Wall",
		},
		externalwarnings = {
			Off = "/external:W0",
			Default = "/external:W3",
			High = "/external:W4",
			Extra = "/external:W4",
			Everything = "/external:W4",
		},
		externalanglebrackets = {
			On = "/external:anglebrackets",
		},
		staticruntime = {
			-- this option must always be emit (does it??)
			_ = function(cfg) return getRuntimeFlag(cfg, false) end,
			-- runtime defaults to dynamic in VS
			Default = function(cfg) return getRuntimeFlag(cfg, false) end,
			On = function(cfg) return getRuntimeFlag(cfg, true) end,
			Off = function(cfg) return getRuntimeFlag(cfg, false) end,
		},
		stringpooling = {
			On = "/GF",
			Off = "/GF-",
		},
		symbols = {
			On = "/Z7"
		},
		unsignedchar = {
			On = "/J",
		},
		omitframepointer = {
			On = "/Oy"
		},
		justmycode = {
			On = "/JMC",
			Off = "/JMC-"
		},
		openmp = {
			On = "/openmp",
			Off = "/openmp-"
		},
		usestandardpreprocessor = {
			On = "/Zc:preprocessor",
			Off = "/Zc:preprocessor-"
		}

	}

	function msc.getsharedflags(cfg)
		local shared = config.mapFlags(cfg, msc.shared)

		-- D9007: '/external:I' requires '/external:W'
		if (#cfg.externalincludedirs > 0 or #cfg.includedirsafter > 0)
			and cfg.externalwarnings == nil
			and isVersionGreaterOrEqualTo(cfg.toolset, "msc-v142")
		then
			table.insert(shared, msc.shared.externalwarnings.Default)
		end
		return shared
	end

	msc.cflags = {
		cdialect = {
			["C11"] = "/std:c11",
			["C17"] = "/std:c17"
		}
	}

	function msc.getcflags(cfg)
		local shared = msc.getsharedflags(cfg)
		local cflags = config.mapFlags(cfg, msc.cflags)
		local flags = table.join(shared, cflags, msc.getwarnings(cfg))
		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	msc.cxxflags = {
		cppdialect = {
			["C++14"] = "/std:c++14",
			["C++17"] = "/std:c++17",
			["C++20"] = "/std:c++20",
			["C++latest"] = "/std:c++latest"
		},
		exceptionhandling = {
			Default = "/EHsc",
			On = "/EHsc",
			SEH = "/EHa",
		},
		rtti = {
			Off = "/GR-"
		},
		sanitize = {
			Address = "/fsanitize=address",
			Fuzzer = "/fsanitize=fuzzer",
		}
	}

	function msc.getcxxflags(cfg)
		local shared = msc.getsharedflags(cfg)
		local cxxflags = config.mapFlags(cfg, msc.cxxflags)
		local flags = table.join(shared, cxxflags, msc.getwarnings(cfg))
		return flags
	end


--
-- Decorate defines for the MSVC command line.
--

	msc.defines = {
		characterset = {
			Default = { '/D"_UNICODE"', '/D"UNICODE"' },
			MBCS = '/D"_MBCS"',
			Unicode = { '/D"_UNICODE"', '/D"UNICODE"' },
			ASCII = { },
		}
	}

	function msc.getdefines(defines, cfg)
		local result

		-- HACK: I need the cfg to tell what the character set defines should be. But
		-- there's lots of legacy code using the old getdefines(defines) signature.
		-- For now, detect one or two arguments and apply the right behavior; will fix
		-- it properly when the I roll out the adapter overhaul
		if cfg and defines then
			result = config.mapFlags(cfg, msc.defines)
		else
			result = {}
		end

		for _, define in ipairs(defines) do
			table.insert(result, '/D"' .. define .. '"')
		end

		if cfg and cfg.exceptionhandling == p.OFF then
			table.insert(result, "/D_HAS_EXCEPTIONS=0")
		end

		return result
	end

	function msc.getundefines(undefines)
		local result = {}
		for _, undefine in ipairs(undefines) do
			table.insert(result, '/U"' .. undefine .. '"')
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
			local fn = p.tools.getrelative(cfg.project, value)
			table.insert(result, "/FI" .. p.quoted(fn))
		end)

		return result
	end

	function msc.getrunpathdirs()
		return {}
	end

--
-- Decorate include file search paths for the MSVC command line.
--

	function msc.getincludedirs(cfg, dirs, extdirs, frameworkdirs, includedirsafter)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = p.tools.getrelative(cfg.project, dir)
			table.insert(result, '-I' ..  p.quoted(dir))
		end

		for _, dir in ipairs(extdirs or {}) do
			dir = p.tools.getrelative(cfg.project, dir)
			if isVersionGreaterOrEqualTo(cfg.toolset, "msc-v142") then
				table.insert(result, '/external:I' ..  p.quoted(dir))
			else
				table.insert(result, '-I' ..  p.quoted(dir))
			end
		end

		for _, dir in ipairs(includedirsafter or {}) do
			dir = p.tools.getrelative(cfg.project, dir)
			if isVersionGreaterOrEqualTo(cfg.toolset, "msc-v142") then
				table.insert(result, '/external:I' ..  p.quoted(dir))
			else
				table.insert(result, '-I' ..  p.quoted(dir))
			end
		end

		return result
	end


--
-- Return a list of linker flags for a specific configuration.
--

	msc.linkerFlags = {
		flags = {
			FatalLinkWarnings = "/WX",
			LinkTimeOptimization = "/LTCG",
			NoIncrementalLink = "/INCREMENTAL:NO",
			NoManifest = "/MANIFEST:NO",
			OmitDefaultLibrary = "/NODEFAULTLIB",
		},
		kind = {
			SharedLib = "/DLL",
			WindowedApp = "/SUBSYSTEM:WINDOWS"
		},
		symbols = {
			On = "/DEBUG"
		}
	}

	msc.librarianFlags = {
		flags = {
			FatalLinkWarnings = "/WX",
		}
	}

	function msc.getldflags(cfg)
		local map = iif(cfg.kind ~= p.STATICLIB, msc.linkerFlags, msc.librarianFlags)
		local flags = config.mapFlags(cfg, map)

		if cfg.entrypoint then
			-- /ENTRY requires that /SUBSYSTEM is set.
			if cfg.kind == "ConsoleApp" then
				table.insert(flags, "/SUBSYSTEM:CONSOLE")
			elseif cfg.kind ~= "WindowedApp" then -- already set by above map
				table.insert(flags, "/SUBSYSTEM:NATIVE") -- fallback
			end
			table.insert(flags, '/ENTRY:' .. cfg.entrypoint)
		end

		table.insert(flags, 1, "/NOLOGO")

		-- Ignore default libraries
		for i, ignore in ipairs(cfg.ignoredefaultlibraries) do
			-- Add extension if required
			if not msc.getLibraryExtensions()[ignore:match("[^.]+$")] then
				ignore = path.appendextension(ignore, ".lib")
			end
			table.insert(flags, '/NODEFAULTLIB:' .. ignore)
		end

		return flags
	end


--
-- Build a list of additional library directories for a particular
-- project configuration, decorated for the tool command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of decorated additional library directories.
--

	function msc.getLibraryDirectories(cfg)
		local flags = {}
		local dirs = table.join(cfg.libdirs, cfg.syslibdirs)
		for i, dir in ipairs(dirs) do
			dir = p.tools.getrelative(cfg.project, dir)
			table.insert(flags, '/LIBPATH:"' .. dir .. '"')
		end
		return flags
	end


--
-- Return a list of valid library extensions
--

	function msc.getLibraryExtensions()
		return {
			["lib"] = true,
			["obj"] = true,
		}
	end

--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function msc.getlinks(cfg, systemonly, nogroups)
		local links = {}

		-- If we need sibling projects to be listed explicitly, grab them first
		if not systemonly then
			links = config.getlinks(cfg, "siblings", "fullpath")
		end

		-- Then the system libraries, which come undecorated
		local system = config.getlinks(cfg, "system", "fullpath")
		for i = 1, #system do
			-- Add extension if required
			local link = system[i]
			if not p.tools.msc.getLibraryExtensions()[link:match("[^.]+$")] then
				link = path.appendextension(link, ".lib")
			end

			table.insert(links, link)
		end

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



	function msc.getwarnings(cfg)
		local result = {}

		for _, enable in ipairs(cfg.enablewarnings) do
			table.insert(result, '/w1"' .. enable .. '"')
		end

		for _, disable in ipairs(cfg.disablewarnings) do
			table.insert(result, '/wd"' .. disable .. '"')
		end

		for _, fatal in ipairs(cfg.fatalwarnings) do
			table.insert(result, '/we"' .. fatal .. '"')
		end

		return result
	end
