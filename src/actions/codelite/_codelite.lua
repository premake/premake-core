--
-- _codelite.lua
-- Define the CodeLite action(s).
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	newaction {
		trigger         = "codelite",
		shortname       = "CodeLite",
		description     = "CodeLite (experimental)",
	
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc   = { "gcc" },
		},
		
		solutiontemplates = {
			{ ".workspace",  premake.codelite_workspace },
		},
		
		projecttemplates = {
			{ ".project",  premake.codelite_project },
		},

		onclean = function(solutions, projects, targets)
			for _,name in ipairs(solutions) do
				os.remove(name .. "_wsp.mk")
				os.remove(name .. ".tags")
			end
			for _,name in ipairs(projects) do
				os.remove(name .. ".mk")
				os.remove(name .. ".list")
				os.remove(name .. ".out")
			end
		end
	}
