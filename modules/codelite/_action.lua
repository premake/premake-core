--
-- Name:        codelite/_action.lua
-- Purpose:     Define the CodeLite action.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Andrew Gough
--              Manu Evans
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jason Perkins and the Premake project
--

	local p = premake

	newaction
	{
		-- Metadata for the command line and help system

		trigger         = "codelite",
		shortname       = "CodeLite",
		description     = "Generate CodeLite project files",
		module          = "codelite",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "Makefile", "SharedLib", "StaticLib" },
		valid_languages = { "C", "C++" },
		valid_tools     = {
		    cc = { "gcc", "clang", "msc" }
		},

		-- Solution and project generation logic

		onSolution = function(sln)
			p.modules.codelite.generateSolution(sln)
		end,
		onProject = function(prj)
			p.modules.codelite.generateProject(prj)
		end,

		onCleanSolution = function(sln)
			p.modules.codelite.cleanSolution(sln)
		end,
		onCleanProject = function(prj)
			p.modules.codelite.cleanProject(prj)
		end,
		onCleanTarget = function(prj)
			p.modules.codelite.cleanTarget(prj)
		end,
	}
