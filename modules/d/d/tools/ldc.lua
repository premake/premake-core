--
-- ldc.lua
-- Provides LDC-specific configuration strings.
-- Copyright (c) 2002-2011 Jason Perkins and the Premake project
--


	premake.ldc = { }


--
-- Set default tools
--

	premake.ldc.dc    = "ldc2"


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

	premake.ldc.platforms = 
	{
		Native = {
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

	local platforms = premake.ldc.platforms


	--
	-- Returns the target name specific to compiler
	--

	function premake.ldc.gettarget(name)
		return "-of=" .. name
	end


	--
	-- Returns the object directory name specific to compiler
	--

	function premake.ldc.getobjdir(name)
		return "-od=" .. name
	end


	--
	-- Returns a list of compiler flags, based on the supplied configuration.
	--

	function premake.ldc.getflags(cfg)
		local f = table.translate(cfg.flags, flags)

		table.insert(f, platforms[cfg.platform].flags)

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

	function premake.ldc.getldflags(cfg)
		local result = {}

		table.insert(result, platforms[cfg.platform].ldflags)

		return result
	end


	--
	-- Return a list of library search paths.
	--

	function premake.ldc.getlibdirflags(cfg)
		local result = {}

		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L-L' .. _MAKE.esc(value))
		end

		return result
	end


	--
	-- Returns a list of linker flags for library names.
	--

	function premake.ldc.getlinkflags(cfg)
		local result = {}

		for _, value in ipairs(premake.getlinks(cfg, "siblings", "object")) do
			if (value.kind == "StaticLib") then
				local pathstyle = premake.getpathstyle(value)
				local namestyle = premake.getnamestyle(value)
				local linktarget = premake.gettarget(value, "link",  pathstyle, namestyle, cfg.system)
				local rebasedpath = path.rebase(linktarget.fullpath, value.location, cfg.location)
				table.insert(result, rebasedpath)
			elseif (value.kind == "SharedLib") then
				table.insert(result, '-L-l' .. _MAKE.esc(value.linktarget.basename))
			else
				-- TODO When premake supports the creation of frameworks
			end
		end

		for _, value in ipairs(premake.getlinks(cfg, "system", "basename")) do
			if path.getextension(value) == ".framework" then
				table.insert(result, '-L-framework -L' .. _MAKE.esc(path.getbasename(value)))
			else
				table.insert(result, '-L-l' .. _MAKE.esc(value))
			end
		end

		return result
	end


	--
	-- Decorate defines for the ldc command line.
	--

	function premake.ldc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-d-version=' .. def)
		end
		return result
	end



	--
	-- Decorate include file search paths for the ldc command line.
	--

	function premake.ldc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, "-I=" .. _MAKE.esc(dir))
		end
		return result
	end

