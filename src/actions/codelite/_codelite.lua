--
-- _codelite.lua
-- Define the CodeLite action(s).
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	_CODELITE = { }
	

--
-- Translate Premake kind values into CodeLite kind values.
--

	function _CODELITE.kind(value)
		if (value == "ConsoleApp" or value == "WindowedApp") then
			return "Executable"
		elseif (value == "StaticLib") then
			return "Static Library"
		elseif (value == "SharedLib") then
			return "Dynamic Library"
		end
	end
	
	
		
--
-- Write out entries for the files element; called from premake.walksources().
--

	function _CODELITE.files(prj, fname, state, nestlevel)
		local indent = string.rep("  ", nestlevel + 1)
		
		if (state == "GroupStart") then
			io.write(indent .. '<VirtualDirectory Name="' .. path.getname(fname) .. '">\n')
		elseif (state == "GroupEnd") then
			io.write(indent .. '</VirtualDirectory>\n')
		else
			io.write(indent .. '<File Name="' .. fname .. '"/>\n')
		end
	end
	


--
-- The CodeLite action
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
			{ ".workspace",  _TEMPLATES.codelite_workspace },
		},
		
		projecttemplates = {
			{ ".project",  _TEMPLATES.codelite_project },
		},

		onclean = function(solutions, projects, targets)
			for _,name in ipairs(projects) do
				os.remove(name .. ".tags")
				os.remove(name .. ".mk")
				os.remove(name .. "_wsp.mk")
				os.remove(name .. ".list")
				os.remove(name .. ".out")
			end
		end
	}
