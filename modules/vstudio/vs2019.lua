--
-- vs2019.lua
-- Extend the existing exporters with support for Visual Studio 2019.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local vstudio = p.vstudio

---
-- Define the Visual Studio 2019 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2019",
		shortname   = "Visual Studio 2019",
		description = "Generate Visual Studio 2019 project files",

		-- Visual Studio always uses Windows path and naming conventions

		targetos = "windows",
		toolset  = "msc-v142",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None", "Utility" },
		valid_languages = { "C", "C++", "C#", "F#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = function(wks)
			p.vstudio.vs2005.generateSolution(wks)
		end,
		onProject = function(prj)
			p.vstudio.vs2010.generateProject(prj)
		end,
		onRule = function(rule)
			p.vstudio.vs2010.generateRule(rule)
		end,

		onCleanWorkspace = function(wks)
			p.vstudio.cleanSolution(wks)
		end,
		onCleanProject = function(prj)
			p.vstudio.cleanProject(prj)
		end,
		onCleanTarget = function(prj)
			p.vstudio.cleanTarget(prj)
		end,

		pathVars = vstudio.vs2010.pathVars,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			solutionVersion = "12",
			versionName     = "16",
			targetFramework = "4.7.2",
			toolsVersion    = "15.0",
			userToolsVersion = "Current",
			filterToolsVersion = "4.0",
		}
	}
