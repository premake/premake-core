
--
-- dmd.lua
-- Provides dmd-specific configuration strings.
--

	local tdmd = {}

	local project = premake5.project
	local config = premake5.config
	
--
-- Set default tools
--
	tdmd.gcc = {}
    tdmd.gcc.dc = "dmd"

	tdmd.optlink = {}
    tdmd.optlink.dc = "dmd"


--
-- Translation of Premake flags into dmd flags
--

	local flags =
	{
		ExtraWarnings   = "-w",
		Optimize        = "-O",
		Symbols         = "-g",
		SymbolsLikeC    = "-gc",
		Release         = "-release",
		Documentation   = "-D",
-- GCC:		PIC             = "-fPIC",
		Inline          = "-inline",
		GenerateHeader  = "-H",
		GenerateMap     = "-map",
		NoBoundsCheck   = "-noboundscheck",
		NoFloat         = "-nofloat",
		RetainPaths     = "-op",
		Profile         = "-profile",
		Quiet           = "-quiet",
		Verbose         = "-v",
		Test            = "-unittest",
		GenerateJSON    = "-X",
		CodeCoverage    = "-cov",
	}


-- /////////////////////////////////////////////////////////////////////////
-- dmd + GCC toolchain						
-- /////////////////////////////////////////////////////////////////////////

--
-- dmd.gcc flags
--

	tdmd.gcc.sysflags = 
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

	function tdmd.gcc.getsysflags(cfg, field)
		local result = {}

		-- merge in system-level flags
		local system = tdmd.gcc.sysflags[cfg.system]
		if system then
			result = table.join(result, system[field])
		end

		-- merge in architecture-level flags
		local arch = tdmd.gcc.sysflags[cfg.architecture]
		if arch then
			result = table.join(result, arch[field])
		end

		return result
	end



--
-- Returns the target name specific to compiler
--

	function tdmd.gcc.gettarget(name)
		return "-of" .. name
	end


--
-- Returns the object directory name specific to compiler
--

	function tdmd.gcc.getobjdir(name)
		return "-od" .. name
	end


--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function tdmd.gcc.getflags(cfg)
		local flags = tdmd.gcc.getsysflags(cfg, 'flags')

		--table.insert( f, "-v" )
		if cfg.kind == premake.STATICLIB then
			table.insert( flags, "-lib" )
		elseif cfg.kind == premake.SHAREDLIB then
			table.insert( flags, "-shared" )
			if cfg.system ~= premake.WINDOWS then
				table.insert( flags, "-fPIC" )
			end
		end

		if premake.config.isdebugbuild( cfg ) then
			table.insert( flags, "-debug" )
		else
			table.insert( flags, "-release" )
		end

		return flags
	end


	--
	-- Returns a list of linker flags, based on the supplied configuration.
	--

	function tdmd.gcc.getldflags(cfg)
		local flags = {}

		local sysflags = tdmd.gcc.getsysflags(cfg, 'ldflags')
		flags = table.join(flags, sysflags)

		return flags
	end


	--
	-- Return a list of library search paths.
	--

	function tdmd.gcc.getlibdirflags(cfg)
		local result = {}

		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L-L' .. _MAKE.esc(value))
		end

		return result
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
						table.insert(result, project.getrelative(cfg.project, link.linktarget.abspath))
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
				table.insert(result, link)
			else
				table.insert(result, "-L-l" .. path.getbasename(link))
			end
		end

		return result
	end

	--
	-- Decorate defines for the tdmd.gcc command line.
	--

	function tdmd.gcc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-version=' .. def)
		end
		return result
	end


	--
	-- Decorate include file search paths for the GCC command line.
	--

	function tdmd.gcc.getincludedirs(cfg)
		local result = {}
		for _, dir in ipairs(cfg.includedirs) do
			table.insert(result, "-I" .. project.getrelative(cfg.project, dir))
		end
		return result
	end

--
-- Returns makefile-specific configuration rules.
--

	function tdmd.gcc.getmakesettings(cfg)
		local sysflags = tdmd.gcc.sysflags[cfg.architecture] or tdmd.gcc.sysflags[cfg.system] or {}
		return sysflags.cfgsettings
	end


-- /////////////////////////////////////////////////////////////////////////
-- tdmd + OPTLINK toolchain						
-- /////////////////////////////////////////////////////////////////////////

	tdmd.optlink.sysflags = 
	{
		universal = {
			flags    = "",
			ldflags  = "", 
		},
		x32 = { 
			flags    = "",
			ldflags  = "", 
		},
		x64 = { 
			flags    = "",
			ldflags  = "",
		}
	}

	function tdmd.optlink.getsysflags(cfg, field)
		local result = {}

		-- merge in system-level flags
		local system = tdmd.optlink.sysflags[cfg.system]
		if system then
			result = table.join(result, system[field])
		end

		-- merge in architecture-level flags
		local arch = tdmd.optlink.sysflags[cfg.architecture]
		if arch then
			result = table.join(result, arch[field])
		end

		return result
	end

	-- gettarget is common
	tdmd.optlink.gettarget = tdmd.gcc.gettarget
	-- getobjdir is common
	tdmd.optlink.getobjdir = tdmd.gcc.getobjdir
	-- getdefines is common
	tdmd.optlink.getdefines = tdmd.gcc.getdefines
	-- getflags is common
	tdmd.optlink.getflags = tdmd.gcc.getflags


	--
	-- Returns a list of linker flags, based on the supplied configuration.
	--

	function tdmd.optlink.getldflags(cfg)
		local flags = {}

		local sysflags = tdmd.optlink.getsysflags(cfg, 'ldflags')
		flags = table.join(flags, sysflags)

		return flags
	end


	--
	-- Return a list of library search paths.
	--

	function tdmd.optlink.getlibdirflags(cfg)
		local result = {}

--		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
--			table.insert(result, '-L-L' .. _MAKE.esc(value))
--		end

		return result
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

	--
	-- Decorate include file search paths for the GCC command line.
	--

	function tdmd.optlink.getincludedirs(cfg)
		local result = {}
		for _, dir in ipairs(cfg.includedirs) do
			table.insert(result, "-I" .. project.getrelative(cfg.project, dir))
		end
		return result
	end


	-- if we are compiling on windows, we need to specialise to OPTLINK as the linker
-- OR!!!			if cfg.system ~= premake.WINDOWS then
	if string.match( os.getversion().description, "Windows" ) ~= nil then
		premake.tools.dmd = tdmd.optlink
		premake.tools.dmd.sysflags = tdmd.optlink.sysflags
	else
		premake.tools.dmd = tdmd.gcc
		premake.tools.dmd.sysflags = tdmd.gcc.sysflags
	end
	
