--
-- dotnet.lua
-- Interface for the C# compilers, all of which are flag compatible.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	
	premake.dotnet = { }
	local dotnet = premake.dotnet
	
	premake.dotnet.namestyle = "windows"
	

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

	function dotnet.getbuildaction(fcfg)
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
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "csc" for the C# compiler, or
--    "resgen" for the resource compiler.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

	function dotnet.gettoolname(cfg, tool)
		local compilers = {
			msnet = "csc",
			mono = "mcs",
			pnet = "cscc",
		}

		if tool == "csc" then		
			local toolset = _OPTIONS.dotnet or iif(os.is(premake.WINDOWS), "msnet", "mono")
			return compilers[toolset]
		else
			return "resgen"
		end
	end



--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function dotnet.getflags(cfg)
		local result = table.translate(cfg.flags, flags)
		return result		
	end



--
-- Translates the Premake kind into the CSC kind string.
--

	function dotnet.getkind(cfg)
		if (cfg.kind == "ConsoleApp") then
			return "Exe"
		elseif (cfg.kind == "WindowedApp") then
			return "WinExe"
		elseif (cfg.kind == "SharedLib") then
			return "Library"
		end
	end