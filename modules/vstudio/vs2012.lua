--
-- vs2012.lua
-- Extend the existing exporters with support for Visual Studio 2012.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	local vstudio = p.vstudio

---
-- Define the Visual Studio 2010 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2012",
		shortname   = "Visual Studio 2012",
		description = "Generate Visual Studio 2012 project files",

		-- Visual Studio always uses Windows path and naming conventions

		targetos = "windows",
		toolset  = "msc-v110",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None", "Utility" },
		valid_languages = { "C", "C++", "C#", "F#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = function(wks)
			vstudio.vs2005.generateSolution(wks)
		end,
		onProject = function(prj)
			vstudio.vs2010.generateProject(prj)
		end,
		onRule = function(rule)
			vstudio.vs2010.generateRule(rule)
		end,

		onCleanWorkspace = function(wks)
			vstudio.cleanSolution(wks)
		end,
		onCleanProject = function(prj)
			vstudio.cleanProject(prj)
		end,
		onCleanTarget = function(prj)
			vstudio.cleanTarget(prj)
		end,

		pathVars = vstudio.vs2010.pathVars,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			solutionVersion = "12",
			versionName     = "2012",
			targetFramework = "4.5",
			toolsVersion    = "4.0",
		}
	}
