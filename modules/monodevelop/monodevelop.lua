--
-- Name:        monodevelop.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

-- TODO:
-- Xamarin Studio has 'workspaces', which are collections of 'solution's.
-- If premake supports multiple solutions, we should write out a workspace file...


	premake.extensions.monodevelop = {}

	local p = premake
	local vs2010 = p.vstudio.vs2010
	local vstudio = p.vstudio
	local sln2005 = p.vstudio.sln2005
	local solution = p.solution
	local project = p.project
	local config = p.config
	local monodevelop = p.extensions.monodevelop

	monodevelop.support_url = "https://bitbucket.org/premakeext/monodevelop/wiki/Home"

	monodevelop.printf = function( msg, ... )
		printf( "[monodevelop] " .. msg, ...)
	end

	monodevelop.printf( "Premake MonoDevelop Extension (" .. monodevelop.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]; 
	package.path = this_dir .. "actions/vstudio/?.lua;".. package.path


--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function monodevelop.MonoDevelopProperties(sln)
		_p('\tGlobalSection(MonoDevelopProperties) = preSolution')
		if sln.startproject then
			for prj in solution.eachproject(sln) do
				if prj.name == sln.startproject then
-- TODO: fix me!
--					local prjpath = vstudio.projectfile_ng(prj)
--					prjpath = path.translate(path.getrelative(slnpath, prjpath))
--					_p('\t\tStartupItem = %s', prjpath )
				end
			end
		end

		-- NOTE: multiline descriptions, or descriptions with tab's (/n, /t, etc) need to be escaped with @
		-- Looks like: description = @descriptopn with\nnewline and\ttab's.
--		_p('\t\tdescription = %s', 'solution description')

--		_p('\t\tversion = %s', '0.1')
		_p('\tEndGlobalSection')
	end


--
-- Patch some functions
--

	p.override(vstudio, "projectPlatform", function(oldfn, cfg)
		if _ACTION == "monodevelop" then
			if cfg.platform then
				return cfg.buildcfg .. " " .. cfg.platform
			else
				return cfg.buildcfg
			end
		end
		return oldfn(cfg)
	end)

	p.override(vstudio, "archFromConfig", function(oldfn, cfg, win32)
		if _ACTION == "monodevelop" then
			return "Any CPU"
		end
		return oldfn(cfg, win32)
	end)

	p.override(sln2005, "solutionSections", function(oldfn, sln)
		if _ACTION == "monodevelop" then
			return {
				"ConfigurationPlatforms",
--				"SolutionProperties", -- this doesn't seem to be used by MonoDevelop
				"MonoDevelopProperties",
				"NestedProjects",
			}
		end
		return oldfn(prj)
	end)

	sln2005.sectionmap.MonoDevelopProperties = monodevelop.MonoDevelopProperties

	p.override(vstudio, "projectfile", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.iscpp(prj) then
				return p.filename(prj, ".cproj")
			end
		end
		return oldfn(prj)
	end)

	p.override(vstudio, "tool", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.iscpp(prj) then
				return "2857B73E-F847-4B02-9238-064979017E93"
			end
		end
		return oldfn(prj)
	end)


---
-- Identify the type of project being exported and hand it off
-- the right generator.
---

	function monodevelop.generateProject(prj)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(vs2010.esc)

		if project.isdotnet(prj) then
			p.generate(prj, ".csproj", vstudio.cs2005.generate)
			p.generate(prj, ".csproj.user", vstudio.cs2005.generate_user)
		elseif project.iscpp(prj) then
			p.generate(prj, ".cproj", monodevelop.generate)
		end
	end


--
-- Define the MonoDevelop export action.
--

	newaction {
		-- Metadata for the command line and help system

		trigger         = "monodevelop",
		shortname       = "MonoDevelop",
		description     = "Generate MonoDevelop project files",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "gcc"   },
			dotnet = { "mono", "msnet" },
		},

		-- Solution and project generation logic

		onSolution = vstudio.vs2005.generateSolution,
		onProject  = monodevelop.generateProject,

		onCleanSolution = vstudio.cleanSolution,
		onCleanProject  = vstudio.cleanProject,
		onCleanTarget   = vstudio.cleanTarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "10.0.0",
			solutionVersion     = "11",
			versionName         = "2010",
			targetFramework     = "4.0",
			toolsVersion        = "4.0",
		}
	}


--
-- 'require' code to produce the C/C++ .cproj files.
--
	require( "monodevelop_cproj" )
	monodevelop.printf( "Loaded MonoDevelop C/C++ support 'monodevelop_cproj.lua'", v )
