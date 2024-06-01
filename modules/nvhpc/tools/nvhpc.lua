-- nvhpc/tools/nvhpc.lua
-- Toolset adapter for Nvidia HPC

	local p = premake

	p.tools.nvhpc = {}
	local nvhpc = p.tools.nvhpc
	local project = p.project
	local config = p.config

--
-- Returns list of C preprocessor flags for a configuration.
--

	nvhpc.cppflags = {
		system = {
			_ = { "-MD" }
		}
	}

	function nvhpc.getcppflags(cfg)
		local flags = config.mapFlags(cfg, nvhpc.cppflags)
		return flags
	end

--
-- Returns string to be appended to -g
--
	function nvhpc.getdebugformat(cfg)
		local flags = {
			Default = "",
			Dwarf = "-Mdwarf3",
		}
		return flags
	end

--
-- Returns list of C compiler flags for a configuration.
--
	nvhpc.shared = {
		architecture = {
			x86 = "-tp=px",
			x86_64 = "-tp=px",
		},
		flags = {
		},
		floatingpoint = {
		},
		strictaliasing = {
		},
		openmp = {
			On = "-mp"
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Full = "-O3",
		},
		pic = {
			On = "-fpic",
		},
		vectorextensions = {
		},
		isaextensions = {
		},
		warnings = {
			Off = "-w",
		},
		externalwarnings = {
		},
		symbols = function(cfg, mappings)
			local values = nvhpc.getdebugformat(cfg)
			local debugformat = values[cfg.debugformat] or ""
			return {
				On       = "-g" .. debugformat,
				FastLink = "-g" .. debugformat,
				Full     = "-g" .. debugformat,
			}
		end,
		unsignedchar = {
		},
		omitframepointer = {
		},
		compileas = {
		}
	}

	nvhpc.cflags = {
		cdialect = {
		}
	}

	function nvhpc.getcflags(cfg)
		local shared_flags = config.mapFlags(cfg, nvhpc.shared)
		local cflags = config.mapFlags(cfg, nvhpc.cflags)
		local flags = table.join(shared_flags, cflags, nvhpc.getsystemversionflags(cfg))
		flags = table.join(flags, nvhpc.getwarnings(cfg))
		return flags
	end

	function nvhpc.getwarnings(cfg)
		local result = {}
		return result
	end

--
-- Returns C/C++ system version build flags
--

	function nvhpc.getsystemversionflags(cfg)
		local flags = {}

		return flags
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	nvhpc.cxxflags = {
		exceptionhandling = {
			Off = "--no_exceptions"
		},
		flags = {
		},
		cppdialect = {
			["C++03"] = "--c++03",
			["C++11"] = "--c++11",
			["C++14"] = "--c++14",
			["C++17"] = "--c++17",
		},
		rtti = {
		},
		visibility = {
			Default = "-fvisibility=default",
			Hidden = "-fvisibility=hidden",
			Internal = "-fvisibility=internal",
			Protected = "-fvisibility=protected",
		},
		inlinesvisibility = {
		}
	}

	function nvhpc.getcxxflags(cfg)
		local shared_flags = config.mapFlags(cfg, nvhpc.shared)
		local cxxflags = config.mapFlags(cfg, nvhpc.cxxflags)
		local flags = table.join(shared_flags, cxxflags)
		flags = table.join(flags, nvhpc.getwarnings(cfg), nvhpc.getsystemversionflags(cfg))
		return flags
	end


--
-- Decorate defines for the nvhpc command line.
--

	function nvhpc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. p.esc(define))
		end
		return result
	end

	function nvhpc.getundefines(undefines)
		local result = {}
		for _, undefine in ipairs(undefines) do
			table.insert(result, '-U' .. p.esc(undefine))
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

	function nvhpc.getforceincludes(cfg)
		local result = {}

		table.foreachi(cfg.forceincludes, function(value)
			local fn = project.getrelative(cfg.project, value)
			table.insert(result, string.format('-include %s', p.quoted(fn)))
		end)

		return result
	end


--
-- Decorate include file search paths for the Nvidia HPC command line.
--

	function nvhpc.getincludedirs(cfg, dirs, extdirs, frameworkdirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(frameworkdirs or {}) do
				dir = project.getrelative(cfg.project, dir)
				table.insert(result, '-F' .. p.quoted(dir))
			end
		end

		for _, dir in ipairs(extdirs or {}) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-isystem ' .. p.quoted(dir))
		end

		return result
	end


	-- Just copied from GCC
	-- relative pch file path if any
	function nvhpc.getpch(cfg)
		-- If there is no header, or if PCH has been disabled, I can early out
		if not cfg.pchheader or cfg.flags.NoPCH then
			return nil
		end

		-- Visual Studio requires the PCH header to be specified in the same way
		-- it appears in the #include statements used in the source code; the PCH
		-- source actual handles the compilation of the header. GCC compiles the
		-- header file directly, and needs the file's actual file system path in
		-- order to locate it.

		-- To maximize the compatibility between the two approaches, see if I can
		-- locate the specified PCH header on one of the include file search paths
		-- and, if so, adjust the path automatically so the user doesn't have
		-- add a conditional configuration to the project script.

		local pch = cfg.pchheader
		local found = false

		-- test locally in the project folder first (this is the most likely location)
		local testname = path.join(cfg.project.basedir, pch)
		if os.isfile(testname) then
			return project.getrelative(cfg.project, testname)
		else
			-- else scan in all include dirs.
			for _, incdir in ipairs(cfg.includedirs) do
				testname = path.join(incdir, pch)
				if os.isfile(testname) then
					return project.getrelative(cfg.project, testname)
				end
			end
		end

		return project.getrelative(cfg.project, path.getabsolute(pch))
	end

--
-- Return a list of decorated rpaths
--
-- @param cfg
--    The configuration to query.
-- @param dirs
--    List of absolute paths
-- @param mode
--    Output mode
--    - "linker" (default) Linker rpath instructions
--    - "path" List of path relative to configuration target directory
--

	function nvhpc.getrunpathdirs(cfg, dirs, mode)
		local result = {}
		mode = iif (mode == nil, "linker", mode)

		if not (table.contains(os.getSystemTags(cfg.system), "darwin")
				or (cfg.system == p.LINUX)) then
			return result
		end

		for _, fullpath in ipairs(dirs) do
			local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
			if table.contains(os.getSystemTags(cfg.system), "darwin") then
				rpath = "@loader_path/" .. rpath
			elseif (cfg.system == p.LINUX) then
				rpath = iif(rpath == ".", "", "/" .. rpath)
				rpath = "$$ORIGIN" .. rpath
			end

			if mode == "linker" then
				rpath = "-Wl,-rpath,'" .. rpath .. "'"
			end

			table.insert(result, rpath)
		end

		return result
	end

--
-- get the right output flag.
--
	function nvhpc.getsharedlibarg(cfg)
		-- if table.contains(os.getSystemTags(cfg.system), "darwin") then
		--	if cfg.sharedlibtype == "OSXBundle" then
		--		return "-bundle"
		--	elseif cfg.sharedlibtype == "XCTest" then
		--		return "-bundle"
		--	elseif cfg.sharedlibtype == "OSXFramework" then
		--		return "-framework"
		--	else
		--		return "-dynamiclib"
		--	end
		--else
			return "-shared"
		--end
	end


	nvhpc.ldflags = {
		architecture = {
			x86 = "-tp=px",
			x86_64 = "-tp=px",
		},
		flags = {
			-- LinkTimeOptimization = "-flto",
		},
		kind = {
			SharedLib = function(cfg)
				local r = { nvhpc.getsharedlibarg(cfg) }
				if cfg.system == p.WINDOWS and not cfg.flags.NoImportLib then
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
		system = {
		},
		symbols = {
			Off = nvhpc.ldsymbols,
			Default = nvhpc.ldsymbols,
		}
	}

	function nvhpc.getldflags(cfg)
		local flags = config.mapFlags(cfg, nvhpc.ldflags)
		return flags
	end


--
-- Return a list of decorated additional libraries directories.
--

	nvhpc.libraryDirectories = {
		architecture = {
			x86 = function (cfg)
				local r = {}
				if not table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert (r, "-L/usr/lib32")
				end
				return r
			end,
			x86_64 = function (cfg)
				local r = {}
				if not table.contains(os.getSystemTags(cfg.system), "darwin") then
					table.insert (r, "-L/usr/lib64")
				end
				return r
			end,
		},
		system = {
		}
	}

	function nvhpc.getLibraryDirectories(cfg)
		local flags = {}

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths. The call
		-- config.getlinks() all includes cfg.libdirs.
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		if table.contains(os.getSystemTags(cfg.system), "darwin") then
			for _, dir in ipairs(cfg.frameworkdirs) do
				dir = project.getrelative(cfg.project, dir)
				table.insert(flags, '-F' .. p.quoted(dir))
			end
		end

		if cfg.flags.RelativeLinks then
			for _, dir in ipairs(config.getlinks(cfg, "siblings", "directory")) do
				local libFlag = "-L" .. p.project.getrelative(cfg.project, dir)
				if not table.contains(flags, libFlag) then
					table.insert(flags, libFlag)
				end
			end
		end

		for _, dir in ipairs(cfg.syslibdirs) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		local nvhpcFlags = config.mapFlags(cfg, nvhpc.libraryDirectories)
		flags = table.join(flags, nvhpcFlags)

		return flags
	end


--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function nvhpc.getlinks(cfg, systemonly, nogroups)
		local result = {}

		if not systemonly then
			if cfg.flags.RelativeLinks then
				local libFiles = config.getlinks(cfg, "siblings", "basename")
				for _, link in ipairs(libFiles) do
					if string.startswith(link, "lib") then
						link = link:sub(4)
					end
					table.insert(result, "-l" .. link)
				end
			else
				-- Don't use the -l form for sibling libraries, since they may have
				-- custom prefixes or extensions that will confuse the linker. Instead
				-- just list out the full relative path to the library.
				result = config.getlinks(cfg, "siblings", "fullpath")
			end
		end

		-- The "-l" flag is fine for system libraries
		local links = config.getlinks(cfg, "system", "fullpath")
		local static_syslibs = {"-Wl,-Bstatic"}
		local shared_syslibs = {}

		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework")
				table.insert(result, path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				local endswith = function(s, ptrn)
					return ptrn == string.sub(s, -string.len(ptrn))
				end
				local name = path.getname(link)
				-- Check whether link mode decorator is present
				if endswith(name, ":static") then
					name = string.sub(name, 0, -8)
					table.insert(static_syslibs, "-l" .. name)
				elseif endswith(name, ":shared") then
					name = string.sub(name, 0, -8)
					table.insert(shared_syslibs, "-l" .. name)
				else
					table.insert(shared_syslibs, "-l" .. name)
				end
			end
		end

		local move = function(a1, a2)
			local t = #a2
			for i = 1, #a1 do a2[t + i] = a1[i] end
		end
		if #static_syslibs > 1 then
			table.insert(static_syslibs, "-Wl,-Bdynamic")
			move(static_syslibs, result)
		end
		move(shared_syslibs, result)

		if not nogroups and #result > 1 and (cfg.linkgroups == p.ON) then
			table.insert(result, 1, "-Wl,--start-group")
			table.insert(result, "-Wl,--end-group")
		end

		return result
	end


--
-- Returns makefile-specific configuration rules.
--

	nvhpc.makesettings = {
		system = {
		}
	}

	function nvhpc.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, nvhpc.makesettings)
		return table.concat(settings)
	end





	nvhpc.tools = {
		cc = "nvc",
		cxx = "nvc++",
		ar = "ar"
	}
	
	function nvhpc.gettoolname(cfg, tool)
		local value = nvhpc.tools[tool]
		if type(value) == "function" then
			value = value(cfg)
		end
		return value
	end
