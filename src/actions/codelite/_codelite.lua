--
-- _codelite.lua
-- Define the CodeLite action(s).
-- Copyright (c) 2008-2009 Jason Perkins and the Premake project
--

	newaction {
		trigger         = "codelite",
		shortname       = "CodeLite",
		description     = "CodeLite",
	
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc   = { "gcc" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, "{name}.workspace", premake.codelite_workspace)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "{name}.project", premake.codelite_project)
		end,
		
		oncleansolution = function(sln)
			premake.clean.file(sln, "{name}.workspace")
			premake.clean.file(sln, "{name}_wsp.mk")
			premake.clean.file(sln, "{name}.tags")
		end,
		
		oncleanproject = function(prj)
			premake.clean.file(prj, "{name}.project")
			premake.clean.file(prj, "{name}.mk")
			premake.clean.file(prj, "{name}.list")
			premake.clean.file(prj, "{name}.out")
		end
	}
