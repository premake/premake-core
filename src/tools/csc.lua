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
-- Returns the compiler filename (they all use the same arguments)
--

	function premake.csc.getcompilervar(cfg)
		if (_OPTIONS.dotnet == "ms") then
			return "csc"
		elseif (_OPTIONS.dotnet == "mono") then
			return "mcs"
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
