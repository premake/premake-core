--
-- _codeblocks.lua
-- Define the Code::Blocks action(s).
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--


	newaction {
		trigger         = "codeblocks",
		shortname       = "Code::Blocks",
		description     = "Code::Blocks Studio",
		
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc   = { "gcc", "ow" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, "{name}.workspace", premake.codeblocks_workspace)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "{name}.cbp", premake.codeblocks_cbp)
		end,
		
		oncleansolution = function(sln)
			premake.clean.file(sln, "{name}.workspace")
		end,
		
		oncleanproject = function(prj)
			premake.clean.file(prj, "{name}.cbp")
			premake.clean.file(prj, "{name}.depend")
			premake.clean.file(prj, "{name}.layout")
		end
	}
