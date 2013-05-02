--
-- actions/vstudio/vs2010.lua
-- Add support for the Visual Studio 2010 project formats.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vs2010 = {}
	local vs2010 = premake.vstudio.vs2010
	local vstudio = premake.vstudio



---
-- Register a command-line action for Visual Studio 2010.
---

	function vs2010.generateProject(prj)
		if premake5.project.isdotnet(prj) then
			premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
			premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
		else
			premake.generate(prj, ".vcxproj", vstudio.vc2010.generate)
			premake.generate(prj, ".vcxproj.user", vstudio.vc2010.generateUser)
			premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generateFilters)
		end
	end


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

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile" },
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
