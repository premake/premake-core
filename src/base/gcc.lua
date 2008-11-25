--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--

--
-- I don't know if this is the right breakdown or API to individual compilers
-- yet so treat it all as experimental. I won't know until I get the change
-- to implement a few different compilers across different toolset actions.
--
	
	
	premake.tools.gcc = { }
	
	
--
-- CFLAGS
--

	premake.tools.gcc.cflags =
	{
		ExtraWarnings  = "-Wall",
		FatalWarning   = "-Werror",
		NoFramePointer = "-fomit-frame-pointer",
		Optimize       = "-O2",
		OptimizeSize   = "-Os",
		OptimizeSpeed  = "-O3",
		Symbols        = "-g",
	}

	function premake.tools.gcc.make_cflags(cfg)
		local flags = table.translate(cfg.flags, premake.tools.gcc.cflags)
		
		if (cfg.kind == "SharedLib" and not os.is("windows")) then
			table.insert(flags, "-fPIC")
		end

		return table.concat(flags, " ")
	end


--
-- Process the list of libraries for a configuration. Returns a list of linker
-- search paths, followed by a list of link names. Not all compilers need to
-- split up links this way; in that case, return an empty list of search paths
-- and keep the library paths intact.
-- See bug #1729227 for background on why the path must be split for GCC.
--

	function premake.tools.gcc.getlinks(cfg)
		local dirs  = { }
		local names = { }
		for _, link in ipairs(premake.getlibraries(cfg)) do
			local dir  = path.getdirectory(link)
			local name = path.getbasename(link)
			
			if (dir ~= "" and not table.contains(cfg.libdirs, dir) and not table.contains(dirs, dir)) then
				table.insert(dirs, dir)
			end
			
			table.insert(names, name)
		end
		
		return dirs, names
	end
	
	
	
--
-- CPPFLAGS
--

	function premake.tools.gcc.make_cppflags(cfg)
		-- if $(ARCH) contains multiple targets, then disable the incompatible automatic
		-- dependency generation. This allows building universal binaries on MacOSX, sorta.
		return "$(if $(word 2, $(ARCH)), , -MMD)"
	end
	
	
--
-- CXXFLAGS
--

	premake.tools.gcc.cxxflags =
	{
		NoExceptions   = "--no-exceptions",
		NoRTTI         = "--no-rtti",
	}
	
	function premake.tools.gcc.make_cxxflags(cfg)
		local flags = table.translate(cfg.flags, premake.tools.gcc.cxxflags)
		return table.concat(flags, " ")
	end
	

--
-- DEFINES and INCLUDES
--
	
	function premake.tools.gcc.make_defines(cfg)
		return table.implode(cfg.defines, '-D "', '"', ' ')
	end

	
	function premake.tools.gcc.make_includes(cfg)
		return table.implode(cfg.includedirs, '-I "', '"', ' ')
	end
	

--
-- LDFLAGS
--
	
	function premake.tools.gcc.make_ldflags(cfg)
		local flags = { }
		
		if (cfg.kind == "SharedLib") then
			if (not os.is("macosx")) then
				table.insert(flags, "-shared")
			end
			
			-- create import library for DLLs under Windows
			if (os.is("windows") and not cfg.flags.NoImportLib) then
				table.insert(flags, '-Wl,--out-implib="' .. premake.gettargetfile(cfg, "implib", "linux") .. '"')
			end
		end

		if (os.is("windows") and cfg.kind == "WindowedApp") then
			table.insert(flags, "-mwindows")
		end

		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		if (not cfg.flags.Symbols) then
			if (os.is("macosx")) then
				table.insert(flags, "-Wl,-x")
			else
				table.insert(flags, "-s")
			end
		end

		if (os.is("macosx") and table.contains(flags, "Dylib")) then
			table.insert(flags, "-dynamiclib -flat_namespace")
		end
		
		-- need to split path from libraries to avoid runtime errors (see bug #1729227)
		local dirs  = { }
		local names = { }
		for _, link in ipairs(premake.getlibraries(cfg)) do
			local dir  = path.getdirectory(link)
			local name = path.getbasename(link)
			
			if (dir ~= "" and not table.contains(cfg.libdirs, dir) and not table.contains(dirs, dir)) then
				table.insert(dirs, dir)
			end
			
			table.insert(names, name)
		end
		
		return table.concat(flags, " ") .. table.implode(cfg.libdirs, ' -L "', '"').. table.implode(dirs, ' -L "', '"') .. table.implode(names, ' -l "', '"')
	end
	

--
-- SOURCE FILE RULES
--

	function premake.tools.gcc.make_file_rule(file)	
		if (path.iscfile(file)) then
			return "$(CC) $(CFLAGS) -o $@ -c $<"
		else
			return "$(CXX) $(CXXFLAGS) -o $@ -c $<"
		end
	end

