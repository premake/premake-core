--
-- actions/vstudio/vs2012.lua
-- Extend the existing exporters with support for Visual Studio 2012.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	premake.vstudio.vc2012 = {}
	local vstudio = premake.vstudio
	local vc2010 = vstudio.vc2010
	local vc2012 = vstudio.vc2012


---
-- Register a command-line action for Visual Studio 2012.
---

	newaction {
		-- Metadata for the command line and help system
		trigger     = "vs2012",
		shortname   = "Visual Studio 2012",
		description = "Generate Visual Studio 2012 project files",

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
		-- TODO: Merge these with the other actions; no need to replicate each time
		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
		end,

		onproject = function(prj)
			if premake5.project.isdotnet(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
			else
				premake.generate(prj, ".vcxproj", vstudio.vc2010.generate)
				premake.generate(prj, ".vcxproj.user", vstudio.vc2010.generateUser)
				premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generateFilters)
			end
		end,

		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget,

		-- This stuff is specific to the Visual Studio exporters
		vstudioSolutionVersion = 12,
	}


---
-- Add new elements to the configuration properties block of C++ projects.
--

	table.insertafter(vc2010.elements.configurationProperties, "characterSet", "platformToolset")

	function vc2010.platformToolset(cfg)
		if _ACTION > "vs2010" then
			_p(2,'<PlatformToolset>v110</PlatformToolset>')
		end
	end
