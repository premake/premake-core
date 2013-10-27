	--
	-- gdc.lua
	-- Provides GDC-specific configuration strings.
	-- Copyright (c) 2002-2011 Jason Perkins and the Premake project
	--

	premake.tools.gdc = { }

	local gdc = premake.tools.gdc
	local project = premake.project
	local config = premake.config
	

	--
	-- Set default tools
	--

	gdc.dc = "gdc"


	--
	-- Translation of Premake flags into GDC flags
	--

	local flags =
	{
		ExtraWarnings	= "-w",
		Optimize		= "-O2",
		Symbols			= "-g -fdebug",
		SymbolsLikeC	= "-fdebug-c",
		Deprecated		= "-fdeprecated",
		Release			= "-frelease",
		Documentation	= "-fdoc",
		PIC				= "-fPIC",
		NoBoundsCheck	= "-fno-bounds-check",
		NoFloat			= "-nofloat",
		UnitTest		= "-funittest",
		GenerateJSON	= "-fXf",
		Verbose			= "-fd-verbose"
	}



	--
	-- Map platforms to flags
	--

	gdc.sysflags = 
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

	local sysflags = gdc.sysflags

	--
	-- Returns the target name specific to compiler
	--

	function gdc.gettarget(name)
		return "-o " .. name
	end


	--
	-- Returns the object directory name specific to compiler
	--

	function gdc.getobjdir(name)
		return "-fod=" .. name
	end

	function gdc.getsysflags(cfg, field)
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
	function gdc.getflags(cfg)
		local f = gdc.getsysflags(cfg, 'flags')

		--table.insert( f, "-v" )
		if cfg.kind == premake.STATICLIB then
			table.insert( f, "-static" )
		elseif cfg.kind == premake.SHAREDLIB then
			table.insert( f, "-shared" )
			if cfg.system ~= premake.WINDOWS then
				table.insert( f, "-fPIC" )
			end
		end

		if premake.config.isDebugBuild( cfg ) then
			table.insert( f, flags.Symbols )
		else
			table.insert( f, flags.Release )
		end

		return f
	end


	--
	-- Returns a list of linker flags, based on the supplied configuration.
	--

	function gdc.getldflags(cfg)
		local result = {}

		local sysflags = gdc.getsysflags(cfg, 'ldflags')
		table.join(result, sysflags)

		return result
	end


	--
	-- Return a list of library search paths.
	--

	function gdc.getlibdirflags(cfg)
		local result = {}

		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L-L' .. _MAKE.esc(value))
		end

		return result
	end


	--
	-- Returns a list of linker flags for library names.
	--

	function gdc.getlinks(cfg)
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
					table.insert(result, "-Wl,-l" .. linkinfo.basename)
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
				table.insert(result, "-Wl,-l" .. link)
			end
		end

		return result

	end


	--
	-- Decorate defines for the gdc command line.
	--

	function gdc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-fversion=' .. def)
		end
		return result
	end



	--
	-- Decorate include file search paths for the gdc command line.
	--

	function gdc.getincludedirs(cfg)
		local result = {}
		for _, dir in ipairs(cfg.includedirs) do
			table.insert(result, "-I" .. project.getrelative(cfg.project, dir))
		end
		return result
	end

	function gdc.getmakesettings(cfg)
		local sysflags = gdc.sysflags[cfg.architecture] or gdc.sysflags[cfg.system] or {}
		return sysflags.cfgsettings
	end

