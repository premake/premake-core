--
-- clang.lua
-- Clang toolset adapter for Premake
-- Copyright (c) 2013 Jess Perkins and the Premake project
--

	local p = premake
	p.tools.clang = {}
	local clang = p.tools.clang
	local gcc = p.tools.gcc
	local config = p.config



--
-- Build a list of flags for the C preprocessor corresponding to the
-- settings in a particular project configuration.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C preprocessor flags.
--

	function clang.getcppflags(cfg)

		-- Just pass through to GCC for now
		local flags = gcc.getcppflags(cfg)
		return flags

	end


--
-- Build a list of C compiler flags corresponding to the settings in
-- a particular project configuration. These flags are exclusive
-- of the C++ compiler flags, there is no overlap.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C compiler flags.
--

	clang.shared = {
		architecture = gcc.shared.architecture,
		fatalwarnings = {
			Compile = "-Werror"
		},
		flags = gcc.shared.flags,
		floatingpoint = {
			Fast = "-ffast-math",
		},
		strictaliasing = gcc.shared.strictaliasing,
		openmp = gcc.shared.openmp,
		optimize = gcc.shared.optimize,
		pic = gcc.shared.pic,
		vectorextensions = gcc.shared.vectorextensions,
		isaextensions = gcc.shared.isaextensions,
		warnings = gcc.shared.warnings,
		symbols = gcc.shared.symbols,
		unsignedchar = gcc.shared.unsignedchar,
		omitframepointer = gcc.shared.omitframepointer,
		compileas = gcc.shared.compileas,
		sanitize = table.merge(gcc.shared.sanitize, {
			Fuzzer = "-fsanitize=fuzzer",
		}),
		visibility = gcc.shared.visibility,
		inlinesvisibility = gcc.shared.inlinesvisibility,
		linktimeoptimization = gcc.shared.linktimeoptimization
	}

	clang.cflags = table.merge(gcc.cflags, {
	})

	function clang.getcflags(cfg)
		local shared = config.mapFlags(cfg, clang.shared)
		local cflags = config.mapFlags(cfg, clang.cflags)

		local flags = table.join(shared, cflags)
		flags = table.join(flags, clang.getwarnings(cfg), clang.getsystemversionflags(cfg))

		return flags
	end

	function clang.getwarnings(cfg)
		return gcc.getwarnings(cfg)
	end

--
-- Returns system version related build flags
--

	function clang.getsystemversionflags(cfg)
		local flags = {}

		if cfg.system == p.MACOSX or cfg.system == p.IOS then
			local minVersion = p.project.systemversion(cfg)
			if minVersion ~= nil then
				local name = iif(cfg.system == p.MACOSX, "macosx", "iphoneos")
				table.insert (flags, "-m" .. name .. "-version-min=" .. p.project.systemversion(cfg))
			end
		end

		return flags
	end

--
-- Build a list of C++ compiler flags corresponding to the settings
-- in a particular project configuration. These flags are exclusive
-- of the C compiler flags, there is no overlap.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C++ compiler flags.
--

	clang.cxxflags = table.merge(gcc.cxxflags, {
	})

	function clang.getcxxflags(cfg)
		local shared = config.mapFlags(cfg, clang.shared)
		local cxxflags = config.mapFlags(cfg, clang.cxxflags)
		local flags = table.join(shared, cxxflags)
		flags = table.join(flags, clang.getwarnings(cfg), clang.getsystemversionflags(cfg))
		return flags
	end


--
-- Returns a list of defined preprocessor symbols, decorated for
-- the compiler command line.
--
-- @param defines
--    An array of preprocessor symbols to define; as an array of
--    string values.
-- @return
--    An array of symbols with the appropriate flag decorations.
--

	function clang.getdefines(defines)

		-- Just pass through to GCC for now
		local flags = gcc.getdefines(defines)
		return flags

	end

	function clang.getundefines(undefines)

		-- Just pass through to GCC for now
		local flags = gcc.getundefines(undefines)
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

	function clang.getforceincludes(cfg)

		-- Just pass through to GCC for now
		local flags = gcc.getforceincludes(cfg)
		return flags

	end


--
-- Returns a list of include file search directories, decorated for
-- the compiler command line.
--
-- @param cfg
--    The project configuration.
-- @param dirs
--    An array of include file search directories; as an array of
--    string values.
-- @param extdirs
--    An array of include file search directories for external includes;
--    as an array of string values.
-- @param frameworkdirs
--    An array of file search directories for the framework includes;
--    as an array of string vlaues
-- @param includedirsafter
--    An array of include file search directories for includes after system;
--    as an array of string values.
-- @return
--    An array of symbols with the appropriate flag decorations.
--

	function clang.getincludedirs(cfg, dirs, extdirs, frameworkdirs, includedirsafter)

		-- Just pass through to GCC for now
		local flags = gcc.getincludedirs(cfg, dirs, extdirs, frameworkdirs, includedirsafter)
		return flags

	end

	clang.getrunpathdirs = gcc.getrunpathdirs

--
-- get the right output flag.
--
	function clang.getsharedlibarg(cfg)
		return gcc.getsharedlibarg(cfg)
	end

--
-- Build a list of linker flags corresponding to the settings in
-- a particular project configuration.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of linker flags.
--

	clang.ldflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
			WASM32 = "-m32",
			WASM64 = "-m64",
		},
		fatalwarnings = {
			Link = "-Wl,--fatal-warnings",
		},
		linktimeoptimization = clang.shared.linktimeoptimization,
		kind = {
			SharedLib = function(cfg)
				local r = { clang.getsharedlibarg(cfg) }
				if cfg.system == "windows" and not cfg.flags.NoImportLib then
					table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
				elseif cfg.system == p.LINUX then
					table.insert(r, '-Wl,-soname=' .. p.quoted(cfg.linktarget.name))
				elseif table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert(r, '-Wl,-install_name,' .. p.quoted('@rpath/' .. cfg.linktarget.name))
				end
				return r
			end,
			WindowedApp = function(cfg)
				if cfg.system == p.WINDOWS then return "-mwindows" end
			end,
		},
		linker = gcc.ldflags.linker,
		sanitize = table.merge(gcc.ldflags.sanitize, {
			Fuzzer = "-fsanitize=fuzzer",
		}),
		system = {
			wii = "$(MACHDEP)",
		}
	}

	function clang.getldflags(cfg)
		local flags = config.mapFlags(cfg, clang.ldflags)
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

	function clang.getLibraryDirectories(cfg)

		-- Just pass through to GCC for now
		local flags = gcc.getLibraryDirectories(cfg)
		return flags

	end


--
-- Build a list of libraries to be linked for a particular project
-- configuration, decorated for the linker command line.
--
-- @param cfg
--    The project configuration.
-- @param systemOnly
--    Boolean flag indicating whether to link only system libraries,
--    or system libraries and sibling projects as well.
-- @return
--    A list of libraries to link, decorated for the linker.
--

	function clang.getlinks(cfg, systemonly, nogroups)
		return gcc.getlinks(cfg, systemonly, nogroups)
	end


--
-- Return a list of makefile-specific configuration rules. This will
-- be going away when I get a chance to overhaul these adapters.
--
-- @param cfg
--    The project configuration.
-- @return
--    A list of additional makefile rules.
--

	function clang.getmakesettings(cfg)

		-- Just pass through to GCC for now
		local flags = gcc.getmakesettings(cfg)
		return flags

	end


--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment. I will
-- be moving these into global configuration blocks when I get
-- the chance.
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

	clang.tools = {
		cc = "clang",
		cxx = "clang++",
		ar = function(cfg) return iif(cfg.linktimeoptimization == "On", "llvm-ar", "ar") end,
		rc = "windres"
	}

	function clang.gettoolname(cfg, tool)
		local toolset, version = p.tools.canonical(cfg.toolset or p.CLANG)
		local value = clang.tools[tool]
		if type(value) == "function" then
			value = value(cfg)
		end
		if toolset == p.tools.clang and version ~= nil then
			value = value .. "-" .. version
		end
		return value
	end
