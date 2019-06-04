--
-- d/tools/gdc.lua
-- Provides GDC-specific configuration strings.
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake
	p.tools.gdc = { }

	local gdc = p.tools.gdc
	local project = p.project
	local config = p.config
	local d = p.modules.d

	--
	-- Set default tools
	--

	gdc.dc = "gdc"


--
-- Returns list of D compiler flags for a configuration.
--

	gdc.dflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			Documentation			= "-fdoc",
			FatalWarnings			= "-Werror",
			GenerateHeader			= "-fintfc",
			GenerateJSON			= "-fX",
--			Release					= "-frelease",
			RetainPaths				= "-op",
			SymbolsLikeC			= "-fdebug-c",
			UnitTest				= "-funittest",
			Verbose					= "-fd-verbose",
			-- THESE ARE THE DMD ARGS...
--			ProfileGC				= "-profile=gc",
--			StackFrame				= "-gs",
--			StackStomp				= "-gx",
--			AllInstantiate			= "-allinst",
--			BetterC					= "-betterC",
--			Main					= "-main",
--			PerformSyntaxCheckOnly	= "-o-",
			ShowTLS					= "-fd-vtls",
--			ShowGC					= "-vgc",
--			IgnorePragma			= "-ignore",
			ShowDependencies		= "-fdeps",
		},
		boundscheck = {
			Off = "-fno-bounds-check",
--			On = "-boundscheck=on",
--			SafeOnly = "-boundscheck=safeonly",
		},
		deprecatedfeatures = {
			Allow = "-fdeprecated",
--			Warn = "-dw",
--			Error = "-de",
		},
		floatingpoint = {
			Fast = "-ffast-math",
			Strict = "-ffloat-store",
		},
		optimize = {
			Off = "-O0",
			On = "-O2 -finline-functions",
			Debug = "-Og",
			Full = "-O3 -finline-functions",
			Size = "-Os -finline-functions",
			Speed = "-O3 -finline-functions",
		},
		pic = {
			On = "-fPIC",
		},
		vectorextensions = {
			AVX = "-mavx",
			SSE = "-msse",
			SSE2 = "-msse2",
		},
		warnings = {
--			Default = "-w",	-- TODO: check this...
			High = "-Wall",
			Extra = "-Wall -Wextra",
		},
		symbols = {
			On = "-g",
			FastLink = "-g",
			Full = "-g -gf",
		}
	}

	function gdc.getdflags(cfg)
		local flags = config.mapFlags(cfg, gdc.dflags)

		if config.isDebugBuild(cfg) then
			table.insert(flags, "-fdebug")
		else
			table.insert(flags, "-frelease")
		end

		if cfg.flags.Documentation then
			if cfg.docname then
				table.insert(flags, "-fdoc-file=" .. p.quoted(cfg.docname))
			end
			if cfg.docdir then
				table.insert(flags, "-fdoc-dir=" .. p.quoted(cfg.docdir))
			end
		end
		if cfg.flags.GenerateHeader then
			if cfg.headername then
				table.insert(flags, "-fintfc-file=" .. p.quoted(cfg.headername))
			end
			if cfg.headerdir then
				table.insert(flags, "-fintfc-dir=" .. p.quoted(cfg.headerdir))
			end
		end

		return flags
	end


--
-- Decorate versions for the DMD command line.
--

	function gdc.getversions(versions, level)
		local result = {}
		for _, version in ipairs(versions) do
			table.insert(result, '-fversion=' .. version)
		end
		if level then
			table.insert(result, '-fversion=' .. level)
		end
		return result
	end


--
-- Decorate debug constants for the DMD command line.
--

	function gdc.getdebug(constants, level)
		local result = {}
		for _, constant in ipairs(constants) do
			table.insert(result, '-fdebug=' .. constant)
		end
		if level then
			table.insert(result, '-fdebug=' .. level)
		end
		return result
	end


--
-- Decorate import file search paths for the DMD command line.
--

	function gdc.getimportdirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end
		return result
	end


--
-- Decorate import file search paths for the DMD command line.
--

	function gdc.getstringimportdirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-J' .. p.quoted(dir))
		end
		return result
	end


--
-- Returns the target name specific to compiler
--

	function gdc.gettarget(name)
		return "-o " .. name
	end


--
-- Return a list of LDFLAGS for a specific configuration.
--

	gdc.ldflags = {
		architecture = {
			x86 = { "-m32" },
			x86_64 = { "-m64" },
		},
		kind = {
			SharedLib = function(cfg)
				local r = { iif(cfg.system == p.MACOSX, "-dynamiclib", "-shared") }
				if cfg.system == "windows" and not cfg.flags.NoImportLib then
					table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
				end
				return r
			end,
			WindowedApp = function(cfg)
				if cfg.system == p.WINDOWS then return "-mwindows" end
			end,
		},
	}

	function gdc.getldflags(cfg)
		local flags = config.mapFlags(cfg, gdc.ldflags)
		return flags
	end


--
-- Return a list of decorated additional libraries directories.
--

	gdc.libraryDirectories = {
		architecture = {
			x86 = "-L/usr/lib",
			x86_64 = "-L/usr/lib64",
		}
	}

	function gdc.getLibraryDirectories(cfg)
		local flags = config.mapFlags(cfg, gdc.libraryDirectories)

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-Wl,-L' .. project.getrelative(cfg.project, dir))
		end

		return flags
	end


--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function gdc.getlinks(cfg, systemonly)
		local result = {}

		local links
		if not systemonly then
			links = config.getlinks(cfg, "siblings", "object")
			for _, link in ipairs(links) do
				-- skip external project references, since I have no way
				-- to know the actual output target path
				if not link.project.external then
					if link.kind == p.STATICLIB then
						-- Don't use "-l" flag when linking static libraries; instead use
						-- path/libname.a to avoid linking a shared library of the same
						-- name if one is present
						table.insert(result, "-Wl," .. project.getrelative(cfg.project, link.linktarget.abspath))
					else
						table.insert(result, "-Wl,-l" .. link.linktarget.basename)
					end
				end
			end
		end

		-- The "-l" flag is fine for system libraries
		links = config.getlinks(cfg, "system", "fullpath")
		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework " .. path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, "-Wl," .. link)
			else
				table.insert(result, "-Wl,-l" .. path.getbasename(link))
			end
		end

		return result
	end


--
-- Returns makefile-specific configuration rules.
--

	gdc.makesettings = {
	}

	function gdc.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, gdc.makesettings)
		return table.concat(settings)
	end


--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "dc" for the D compiler, or "ar" for the static linker.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

	gdc.tools = {
		ps3 = {
			dc = "ppu-lv2-gdc",
			ar = "ppu-lv2-ar",
		},
	}

	function gdc.gettoolname(cfg, tool)
		local names = gdc.tools[cfg.architecture] or gdc.tools[cfg.system] or {}
		local name = names[tool]
		return name or gdc[tool]
	end
