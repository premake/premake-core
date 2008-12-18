--
-- csc.lua
-- Interface for the C# compilers, all of which are flag compatible.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--

	
	premake.csc = { }
	

--
-- Translation of Premake flags into CSC flags
--

	local flags =
	{
		FatalWarning   = "/warnaserror",
		Optimize       = "/optimize",
		OptimizeSize   = "/optimize",
		OptimizeSpeed  = "/optimize",
		Symbols        = "/debug",
		Unsafe         = "/unsafe"
	}


--
-- Return the default build action for a given file, based on the file extension.
--

	function premake.csc.getbuildaction(fcfg)
		local ext = path.getextension(fcfg.name):lower()
		if fcfg.buildaction == "Compile" or ext == ".cs" then
			return "Compile"
		elseif fcfg.buildaction == "Embed" or ext == ".resx" then
			return "EmbeddedResource"
		elseif fcfg.buildaction == "Copy" or ext == ".asax" or ext == ".aspx" then
			return "Content"
		else
			return "None"
		end
	end
	
	
	
--
-- Returns the compiler filename (they all use the same arguments)
--

	function premake.csc.getcompilervar(cfg)
		if (_OPTIONS.dotnet == "ms") then
			return "csc"
		elseif (_OPTIONS.dotnet == "mono") then
			return "gmcs"
		else
			return "cscc"
		end
	end



--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function premake.csc.getflags(cfg)
		local result = table.translate(cfg.flags, flags)
		return result		
	end



--
-- Translates the Premake kind into the CSC kind string.
--

	function premake.csc.getkind(cfg)
		if (cfg.kind == "ConsoleApp") then
			return "Exe"
		elseif (cfg.kind == "WindowedApp") then
			return "WinExe"
		elseif (cfg.kind == "SharedLib") then
			return "Library"
		end
	end