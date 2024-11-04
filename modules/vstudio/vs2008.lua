--
-- vs2008.lua
-- Add support for the Visual Studio 2008 project formats.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vs2008 = {}
	local vs2008 = p.vstudio.vs2008
	local vstudio = p.vstudio


---
-- Define the Visual Studio 2008 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2008",
		shortname   = "Visual Studio 2008",
		description = "Generate Visual Studio 2008 project files",

		-- Visual Studio always uses Windows path and naming conventions

		targetos = "windows",
		toolset  = "msc-v90",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None" },
		valid_languages = { "C", "C++", "C#", "F#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = vstudio.vs2005.generateSolution,
		onProject   = vstudio.vs2005.generateProject,

		onCleanWorkspace = vstudio.cleanSolution,
		onCleanProject   = vstudio.cleanProject,
		onCleanTarget    = vstudio.cleanTarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "9.0.30729",
			solutionVersion     = "10",
			versionName         = "2008",
			toolsVersion        = "3.5",
		}
	}
