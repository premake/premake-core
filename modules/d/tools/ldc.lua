--
-- ldc.lua
-- Provides LDC-specific configuration strings.
-- Copyright (c) 2002-2011 Jason Perkins and the Premake project
--

	premake.tools.ldc = { }

	local ldc = premake.tools.ldc
	local project = premake5.project
	local config = premake5.config
	
    local d = premake.extensions.d


--
-- Set default tools
--

	ldc.dc    = "ldc2"
	ldc.namestyle = "posix"

--
-- Translation of Premake flags into GCC flags
--

	local flags =
	{
		ExtraWarnings   = "-w",
		Optimize        = "-O2",
		Symbols         = "-g",
		SymbolsLikeC    = "-gc",
		Release         = "-release",
		Documentation   = "-D",
		GenerateHeader  = "-H",
		RetainPaths     = "-op",
		Verbose         = "-v",
		Test            = "-unittest",
	}



--
-- Map platforms to flags
--

	ldc.sysflags = 
	{
		universal = {
			flags    = "",
			ldflags  = "", 
		},
		x32 = { 
			flags    = "-m32",
			ldflags  = "-L-L/usr/lib", 
		},
		x64 = { 
			flags    = "-m64",
			ldflags  = "-L-L/usr/lib64",
		}
	}

	local sysflags = ldc.sysflags

	--
	-- Returns the target name specific to compiler
	--

	function ldc.gettarget(name)
		return "-of=" .. name
	end

	--
	-- Returns the object directory name specific to compiler
	--

	function ldc.getobjdir(name)
		return "-od=" .. name
	end


	function ldc.getsysflags(cfg, field)
		local result = {}

		-- merge in system-level flags
		local system = sysflags[cfg.system]
		if system then
			result = table.join(result, system[field])
		end

		-- merge in architecture-level flags
		local arch = sysflags[cfg.architecture]
		if arch then
			result = table.join(result, arch[field])
		end

		return result
	end


	--
	-- Returns a list of compiler flags, based on the supplied configuration.
	--

	function ldc.getflags(cfg)
		local f = ldc.getsysflags(cfg, 'flags')

		--table.insert( f, "-v" )
		if cfg.kind == "StaticLib" then
			table.insert( f, "-lib" )
		elseif cfg.kind == "SharedLib" and cfg.system ~= "windows" then
			table.insert( f, "-relocation-model=pic" )
		end

		if premake.config.isdebugbuild( cfg ) then
			table.insert( f, "-d-debug" )
		else
			table.insert( f, "-release" )
		end
		return f
	end

	--
	-- Returns a list of linker flags, based on the supplied configuration.
	--

	function ldc.getldflags(cfg)
		local result = {}

		local sysflags = ldc.getsysflags(cfg, 'ldflags')
		table.join(result, sysflags)

		return result
	end


	--
	-- Return a list of library search paths.
	--

	function ldc.getlibdirflags(cfg)
		local result = {}

		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L-L' .. _MAKE.esc(value))
		end

		return result
	end


	--
	-- Returns a list of linker flags for library names.
	--

	function ldc.getlinks(cfg)
		local result = {}

		local links = config.getlinks(cfg, "dependencies", "object")
		for _, link in ipairs(links) do
			-- skip external project references, since I have no way
			-- to know the actual output target path
			if not link.project.externalname then
				local linkinfo = config.getlinkinfo(link)
				if link.kind == premake.STATICLIB then
					-- Don't use "-l" flag when linking static libraries; instead use 
					-- path/libname.a to avoid linking a shared library of the same
					-- name if one is present
					table.insert(result, project.getrelative(cfg.project, linkinfo.abspath))
				else
					table.insert(result, "-L-l" .. linkinfo.basename)
				end
			end
		end

		-- The "-l" flag is fine for system libraries
		links = config.getlinks(cfg, "system", "basename")
		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework " .. path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				table.insert(result, "-L-l" .. link)
			end
		end

		return result

	end


	--
	-- Decorate defines for the ldc command line.
	--

	function ldc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-d-version=' .. def)
		end
		return result
	end



	--
	-- Decorate include file search paths for the ldc command line.
	--

	function ldc.getincludedirs(cfg)
		local result = {}
		for _, dir in ipairs(cfg.includedirs) do
			table.insert(result, "-I=" .. project.getrelative(cfg.project, dir))
		end
		return result
	end

	function ldc.getmakesettings(cfg)
		local sysflags = ldc.sysflags[cfg.architecture] or ldc.sysflags[cfg.system] or {}
		return sysflags.cfgsettings
	end

