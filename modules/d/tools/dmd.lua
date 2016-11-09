--
-- d/tools/dmd.lua
-- Provides dmd-specific configuration strings.
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local tdmd = {}

	local project = premake.project
	local config = premake.config
    local d = premake.modules.d

--
-- Set default tools
--
	tdmd.gcc = {}
	tdmd.gcc.dc = "dmd"

	tdmd.optlink = {}
	tdmd.optlink.dc = "dmd"


-- /////////////////////////////////////////////////////////////////////////
-- dmd + GCC toolchain
-- /////////////////////////////////////////////////////////////////////////

--
-- Return a list of LDFLAGS for a specific configuration.
--

	tdmd.gcc.ldflags = {
		architecture = {
			x86 = { "-m32" },
			x86_64 = { "-m64" },
		},
		kind = {
			SharedLib = "-shared",
			StaticLib = "-lib",
		}
	}

	function tdmd.gcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, tdmd.gcc.ldflags)
		return flags
	end


--
-- Return a list of decorated additional libraries directories.
--

	tdmd.gcc.libraryDirectories = {
		architecture = {
			x86 = "-L-L/usr/lib",
			x86_64 = "-L-L/usr/lib64",
		}
	}

	function tdmd.gcc.getLibraryDirectories(cfg)
		local flags = config.mapFlags(cfg, tdmd.gcc.libraryDirectories)

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L-L' .. project.getrelative(cfg.project, dir))
		end

		return flags
	end


--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function tdmd.gcc.getlinks(cfg, systemonly)
		local result = {}

		local links
		if not systemonly then
			links = config.getlinks(cfg, "siblings", "object")
			for _, link in ipairs(links) do
				-- skip external project references, since I have no way
				-- to know the actual output target path
				if not link.project.external then
					if link.kind == premake.STATICLIB then
						-- Don't use "-l" flag when linking static libraries; instead use
						-- path/libname.a to avoid linking a shared library of the same
						-- name if one is present
						table.insert(result, "-L" .. project.getrelative(cfg.project, link.linktarget.abspath))
					else
						table.insert(result, "-L-l" .. link.linktarget.basename)
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
				table.insert(result, "-L" .. link)
			else
				table.insert(result, "-L-l" .. path.getbasename(link))
			end
		end

		return result
	end


-- /////////////////////////////////////////////////////////////////////////
-- tdmd + OPTLINK toolchain
-- /////////////////////////////////////////////////////////////////////////

--
-- Return a list of LDFLAGS for a specific configuration.
--

	tdmd.optlink.ldflags = {
		architecture = {
			x86 = { "-m32" },
			x86_64 = { "-m64" },
		},
		kind = {
			SharedLib = "-shared",
			StaticLib = "-lib",
		}
	}

	function tdmd.optlink.getldflags(cfg)
		local flags = config.mapFlags(cfg, tdmd.optlink.ldflags)
		return flags
	end


--
-- Return a list of decorated additional libraries directories.
--

	function tdmd.optlink.getLibraryDirectories(cfg)
		local flags = {}

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-Llib "' .. project.getrelative(cfg.project, dir) .. '"')
		end

		return flags
	end


--
-- Returns a list of linker flags for library names.
--

	function tdmd.optlink.getlinks(cfg)
		local result = {}

		local links = config.getlinks(cfg, "dependencies", "object")
		for _, link in ipairs(links) do
			-- skip external project references, since I have no way
			-- to know the actual output target path
			if not link.project.externalname then
				local linkinfo = config.getlinkinfo(link)
				if link.kind == premake.STATICLIB then
					table.insert(result, project.getrelative(cfg.project, linkinfo.abspath))
				end
			end
		end

		-- The "-l" flag is fine for system libraries
		links = config.getlinks(cfg, "system", "basename")
		for _, link in ipairs(links) do
			if path.isobjectfile(link) then
				table.insert(result, link)
			elseif path.hasextension(link, premake.systems[cfg.system].staticlib.extension) then
				table.insert(result, link)
			end
		end

		return result

	end


-- /////////////////////////////////////////////////////////////////////////
-- common dmd code (either toolchain)
-- /////////////////////////////////////////////////////////////////////////

	-- if we are compiling on windows, we need to specialise to OPTLINK as the linker
-- OR!!!			if cfg.system ~= premake.WINDOWS then
	if string.match( os.getversion().description, "Windows" ) ~= nil then
		-- TODO: on windows, we may use OPTLINK or MSLINK (for Win64)...
--		printf("TODO: select proper linker for 32/64 bit code")

		premake.tools.dmd = tdmd.optlink
	else
		premake.tools.dmd = tdmd.gcc
	end

	local dmd = premake.tools.dmd


--
-- Returns list of D compiler flags for a configuration.
--

	dmd.dflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			CodeCoverage	= "-cov",
			Deprecated		= "-d",
			Documentation	= "-D",
			FatalWarnings	= "-w",
			GenerateHeader	= "-H",
			GenerateJSON	= "-X",
			GenerateMap		= "-map",
			NoBoundsCheck	= "-noboundscheck",
			Profile			= "-profile",
			Quiet			= "-quiet",
--			Release			= "-release",
			RetainPaths		= "-op",
			SymbolsLikeC	= "-gc",
			UnitTest		= "-unittest",
			Verbose			= "-v",
		},
		floatingpoint = {
			None = "-nofloat",
		},
		optimize = {
			On = "-O -inline",
			Full = "-O -inline",
			Size = "-O -inline",
			Speed = "-O -inline",
		},
		pic = {
			On = "-fPIC",
		},
		warnings = {
			Default = "-wi",
			Extra = "-wi",
		},
		symbols = {
			On = "-g",
		}
	}

	function dmd.getdflags(cfg)
		local flags = config.mapFlags(cfg, dmd.dflags)

		if config.isDebugBuild(cfg) then
			table.insert(flags, "-debug")
		else
			table.insert(flags, "-release")
		end

		-- TODO: When DMD gets CRT options, map StaticRuntime and DebugRuntime

		if cfg.flags.Documentation then
			if cfg.docname then
				table.insert(flags, "-Df" .. premake.quoted(cfg.docname))
			end
			if cfg.docdir then
				table.insert(flags, "-Dd" .. premake.quoted(cfg.docdir))
			end
		end
		if cfg.flags.GenerateHeader then
			if cfg.headername then
				table.insert(flags, "-Hf" .. premake.quoted(cfg.headername))
			end
			if cfg.headerdir then
				table.insert(flags, "-Hd" .. premake.quoted(cfg.headerdir))
			end
		end

		return flags
	end


--
-- Decorate versions for the DMD command line.
--

	function dmd.getversions(versions, level)
		local result = {}
		for _, version in ipairs(versions) do
			table.insert(result, '-version=' .. version)
		end
		if level then
			table.insert(result, '-version=' .. level)
		end
		return result
	end


--
-- Decorate debug constants for the DMD command line.
--

	function dmd.getdebug(constants, level)
		local result = {}
		for _, constant in ipairs(constants) do
			table.insert(result, '-debug=' .. constant)
		end
		if level then
			table.insert(result, '-debug=' .. level)
		end
		return result
	end


--
-- Decorate import file search paths for the DMD command line.
--

	function dmd.getimportdirs(cfg, dirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. premake.quoted(dir))
		end
		return result
	end


--
-- Returns the target name specific to compiler
--

	function dmd.gettarget(name)
		return "-of" .. name
	end


--
-- Returns makefile-specific configuration rules.
--

	dmd.makesettings = {
	}

	function dmd.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, dmd.makesettings)
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

	dmd.tools = {
		-- dmd will probably never support any foreign architectures...?
	}

	function dmd.gettoolname(cfg, tool)
		local names = dmd.tools[cfg.architecture] or dmd.tools[cfg.system] or {}
		local name = names[tool]
		return name or dmd[tool]
	end
