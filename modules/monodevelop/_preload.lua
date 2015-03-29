--
-- Name:        monodevelop/_preload.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

-- TODO:
-- MonoDevelop/Xamarin Studio has 'workspaces', which are collections of 'solution's.
-- If premake supports multiple solutions, we should write out a workspace file...

	local p = premake

	newaction
	{
		-- Metadata for the command line and help system

		trigger         = "monodevelop", -- TODO: I'd kinda like an alias 'xamarinstudio' aswell...
		shortname       = "MonoDevelop",
		description     = "Generate MonoDevelop/Xamarin Studio project files",
		module          = "monodevelop",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "gcc" },
			dotnet = { "mono", "msnet" },
		},

		-- Solution and project generation logic

		onSolution = function(sln)
			p.vstudio.vs2005.generateSolution(sln)
		end,
		onProject = function(prj)
			p.modules.monodevelop.generateProject(prj)
		end,

		onCleanSolution = function(sln)
			p.vstudio.cleanSolution(sln)
		end,
		onCleanProject = function(prj)
			p.vstudio.cleanProject(prj)
		end,
		onCleanTarget = function(prj)
			p.vstudio.cleanTarget(prj)
		end,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "10.0.0",
			solutionVersion     = "12",
			versionName         = "2012",
			targetFramework     = "4.5",
			toolsVersion        = "4.0",
		},
	}
