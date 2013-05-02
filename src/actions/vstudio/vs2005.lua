--
-- actions/vstudio/vs2005.lua
-- Add support for the  Visual Studio 2005 project formats.
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vs2005 = {}
	local vs2005 = premake.vstudio.vs2005
	local vstudio = premake.vstudio


---
-- Register a command-line action for Visual Studio 2006.
---

	function vs2005.generateSolution(sln)
		premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
	end


	function vs2005.generateProject(prj)
		if premake5.project.isdotnet(prj) then
			premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
			premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
		else
			premake.generate(prj, ".vcproj", vstudio.vc200x.generate)
			premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user)
		end
	end


	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2005",
		shortname   = "Visual Studio 2005",
		description = "Generate Visual Studio 2005 project files",

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
		onproject  = vstudio.vs2005.generateProject,

		oncleansolution = vstudio.cleanSolution,
		oncleanproject  = vstudio.cleanProject,
		oncleantarget   = vstudio.cleanTarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "8.0.50727",
			solutionVersion     = "9",
		}
	}
