--
-- actions/vstudio/vs2012.lua
-- Extend the existing exporters with support for Visual Studio 2012.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local cs2005 = vstudio.cs2005
	local vc2010 = vstudio.vc2010

	local p = premake


---
-- Define the Visual Studio 2010 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2012",
		shortname   = "Visual Studio 2012",
		description = "Generate Visual Studio 2012 project files",

		-- Visual Studio always uses Windows path and naming conventions

		os = "windows",

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
			solutionVersion = "12",
			versionName     = "2012",
			targetFramework = "4.5",
			toolsVersion    = "4.0",
		}
	}

