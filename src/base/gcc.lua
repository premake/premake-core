--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--

	
	premake.gcc = { }
	

--
-- Translation of Premake flags into GCC flags
--

	local cflags =
	{
		ExtraWarnings  = "-Wall",
		FatalWarning   = "-Werror",
		NoFramePointer = "-fomit-frame-pointer",
		Optimize       = "-O2",
		OptimizeSize   = "-Os",
		OptimizeSpeed  = "-O3",
		Symbols        = "-g",
	}

	local cxxflags =
	{
		NoExceptions   = "--no-exceptions",
		NoRTTI         = "--no-rtti",
	}
	



--
-- Returns the compiler ID used by Code::Blocks.
--

	function premake.gcc.getcompilervar(cfg)
		return iif(cfg.language == "C", "CC", "CPP")
	end
	
	

--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function premake.gcc.getcppflags(cfg)
		-- if $(ARCH) contains multiple targets, then disable the incompatible automatic
		-- dependency generation. This allows building universal binaries on MacOSX, sorta.
		return "$(if $(word 2, $(ARCH)), , -MMD)"
	end

	function premake.gcc.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		if (cfg.kind == "SharedLib" and not os.is("windows")) then
			table.insert(flags, "-fPIC")
		end
		return result		
	end
	
	function premake.gcc.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end
	


--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function premake.gcc.getldflags(cfg)
		local result = { }
		
		if (cfg.kind == "SharedLib") then
			if (not os.is("macosx")) then
				table.insert(result, "-shared")
			end
			
			-- create import library for DLLs under Windows
			if (os.is("windows") and not cfg.flags.NoImportLib) then
				table.insert(result, '-Wl,--out-implib="' .. premake.gettargetfile(cfg, "implib", "linux") .. '"')
			end
		end

		if (os.is("windows") and cfg.kind == "WindowedApp") then
			table.insert(result, "-mwindows")
		end

		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		if (not cfg.flags.Symbols) then
			if (os.is("macosx")) then
				table.insert(result, "-Wl,-x")
			else
				table.insert(result, "-s")
			end
		end

		if (os.is("macosx") and cfg.flags.Dylib) then
			table.insert(result, "-dynamiclib -flat_namespace")
		end
		
		return result
	end
		
	
--
-- Returns a list of linker flags for library search directories and 
-- library names.
--

	function premake.gcc.getlinkflags(cfg)
		local result = { }
		for _, value in ipairs(premake.getlibdirs(cfg)) do
			table.insert(result, '-L "' .. value .. '"')
		end
		for _, value in ipairs(premake.getlibnames(cfg)) do
			table.insert(result, '-l "' .. value .. '"')
		end
		return result
	end
	
	

--
-- Decorate defines for the GCC command line.
--

	function premake.gcc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end


	
--
-- Decorate include file search paths for the GCC command line.
--

	function premake.gcc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, '-I "' .. dir .. '"')
		end
		return result
	end
