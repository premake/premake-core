--
-- Name:        monodevelop/_preload.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

-- TODO:
-- MonoDevelop/Xamarin Studio has 'workspaces', which act like collections of
-- Premake workspaces. If Premake supports multiple workspaces, we should
-- write out a workspace file...

	local p = premake

	newaction
	{
		-- Metadata for the command line and help system

		trigger         = "monodevelop", -- TODO: I'd kinda like an alias 'xamarinstudio' aswell...
		shortname       = "MonoDevelop",
		description     = "Generate MonoDevelop/Xamarin Studio project files",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "gcc" },
			dotnet = { "mono", "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = function(wks)
			p.vstudio.vs2005.generateWorkspace(wks)
		end,
		onProject = function(prj)
			p.modules.monodevelop.generateProject(prj)
		end,

		onCleanWorkspace = function(wks)
			p.vstudio.cleanWorkspace(wks)
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


--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "monodevelop")
	end
