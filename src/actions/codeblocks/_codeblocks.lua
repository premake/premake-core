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
		
		solutiontemplates = {
			{ ".workspace", premake.codeblocks_workspace },
		},
		
		projecttemplates = {
			{ ".cbp", premake.codeblocks_cbp },
		},

		onclean = function(solutions, projects, targets)
			for _,name in ipairs(projects) do
				os.remove(name .. ".depend")
				os.remove(name .. ".layout")
			end
		end
	}
