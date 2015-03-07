---
-- xcode/_action.lua
-- Define the Apple XCode actions.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---

	local p = premake

	newaction {
		trigger     = "xcode4",
		shortname   = "Apple Xcode 4",
		description = "Generate Apple Xcode 4 project files",
		module      = "xcode",

		-- Xcode always uses Mac OS X path and naming conventions

		os = "macosx",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "SharedLib", "StaticLib", "Makefile", "None" },
		valid_languages = { "C", "C++" },
		valid_tools     = {
			cc = { "gcc", "clang" },
		},

		-- Solution and project generation logic

		onSolution = function(sln)
			p.generate(sln, ".xcworkspace/contents.xcworkspacedata", p.modules.xcode.generateWorkspace)
		end,

		onProject = function(prj)
			p.generate(prj, ".xcodeproj/project.pbxproj", p.modules.xcode.generateProject)
		end,
	}
