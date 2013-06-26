--
-- actions/vstudio/vs2010.lua
-- Add support for the Visual Studio 2010 project formats.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vs2010 = {}
	local vs2010 = premake.vstudio.vs2010
	local vstudio = premake.vstudio



---
-- Apply XML escaping on a value to be included in an
-- exported project file.
---

	function vs2010.esc(value)
		value = string.gsub(value, '&',  "&amp;")
		value = value:gsub('<',  "&lt;")
		value = value:gsub('>',  "&gt;")
		value = value:gsub('\r', "&#x0D;")
		value = value:gsub('\n', "&#x0A;")
		return value
	end



---
-- Identify the type of project being exported and hand it off
-- the right generator.
---

	function vs2010.generateProject(prj)
		io.eol = "\r\n"
		io.esc = vs2010.esc

		if premake5.project.isdotnet(prj) then
			premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
			premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
		else
			premake.generate(prj, ".vcxproj", vstudio.vc2010.generate)
			premake.generate(prj, ".vcxproj.user", vstudio.vc2010.generateUser)
			premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generateFilters)
		end
	end



---
-- Define the Visual Studio 2010 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2010",
		shortname   = "Visual Studio 2010",
		description = "Generate Visual Studio 2010 project files",

		-- Visual Studio always uses Windows path and naming conventions

		os = "windows",

		-- temporary, until I can phase out the legacy implementations

		isnextgen = true,

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Solution and project generation logic

		onsolution = vstudio.vs2005.generateSolution,
		onproject  = vstudio.vs2010.generateProject,

		oncleansolution = vstudio.cleanSolution,
		oncleanproject  = vstudio.cleanProject,
		oncleantarget   = vstudio.cleanTarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "8.0.30703",
			solutionVersion     = "11",
			targetFramework     = "4.0",
			toolsVersion        = "4.0",
		}
	}
