--
-- nvcc.lua
-- NVIDIA CUDA Compiler toolset adapter for Premake
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	premake.tools.nvcc = {}
	local nvcc = premake.tools.nvcc
	local gcc = premake.tools.gcc
	local clang = premake.tools.clang
	local msc = premake.tools.msc
	local config = premake.config

	local host_compiler = gcc
	if os.is("linux") then
		host_compiler = gcc
	elseif os.is("macosx") then
		host_compiler = clang
	elseif os.is("windows") then
		host_compiler = msc
	end

	local function prefixFlags(flags, prefix)
		for k, v in pairs(flags) do
			flags[k] = prefix .. " " .. v
		end
		return flags
	end

	local function prefixCompilerFlags(flags)
		local flags = prefixFlags(flags, "-Xcompiler")
		return flags
	end

	local function prefixLinkerFlags(flags)
		local flags = prefixFlags(flags, "-Xlinker")
		return flags
	end

--
-- Build a list of flags for the C preprocessor corresponding to the
-- settings in a particular project configuration.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C preprocessor flags.
--

	function nvcc.getcppflags(cfg)
		return {}
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

	nvcc.cflags = {
		flags = {
			RelocatableDeviceCode = "--relocatable-device-code=true",
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Debug = "-O0",
			Full = "-O3",
			Size = "-Os",
			Speed = "-O3",
		},
	}

	function nvcc.getcflags(cfg)
		local flags = config.mapFlags(cfg, nvcc.cflags)
		local hflags = prefixCompilerFlags(host_compiler.getcflags(cfg))
		flags = table.join(flags, hflags, nvcc.getwarnings(cfg))
		return flags
	end

	function nvcc.getwarnings(cfg)
		return prefixCompilerFlags(host_compiler.getwarnings(cfg))
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

	nvcc.cxxflags = {
		flags = {
			["C++11"] = "--std=c++11",
			["C++14"] = "--std=c++14",
		}
	}

	function nvcc.getcxxflags(cfg)
		local flags = config.mapFlags(cfg, nvcc.cxxflags)
		local hflags = prefixCompilerFlags(host_compiler.getcxxflags(cfg))
		flags = table.join(flags, hflags)
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

	function nvcc.getdefines(defines)
		-- Just pass through to GCC (same interface)
		local flags = gcc.getdefines(defines)
		return flags
	end

	function nvcc.getundefines(undefines)
		-- Just pass through to GCC (same interface)
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

	function nvcc.getforceincludes(cfg)
		-- Just pass through to GCC (same interface)
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
-- @return
--    An array of symbols with the appropriate flag decorations.
--

	function nvcc.getincludedirs(cfg, dirs, sysdirs)
		-- Just pass through to GCC (same interface)
		local flags = gcc.getincludedirs(cfg, dirs, sysdirs)
		return flags
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

	nvcc.ldflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		kind = {
			SharedLib = "-shared"
		}
	}

	function nvcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, nvcc.ldflags)
		local hflags = prefixLinkerFlags(host_compiler.getldflags(cfg))
		flags = table.join(flags, hflags)
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

	function nvcc.getLibraryDirectories(cfg)
		-- Just pass through to GCC (same interface)
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

	function nvcc.getlinks(cfg, systemOnly)
		-- Just pass through to GCC (same interface)
		return gcc.getlinksonly(cfg, systemOnly)
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

	function nvcc.getmakesettings(cfg)
		return nil
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

	nvcc.tools = {
		cc = "nvcc",
		cxx = "nvcc",
		ar = "nvcc --lib"
	}

	function nvcc.gettoolname(cfg, tool)
		return nvcc.tools[tool]
	end
