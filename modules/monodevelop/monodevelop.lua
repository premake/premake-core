--
-- Name:        monodevelop.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013 Manu Evans and the Premake project
--

	premake.extensions.monodevelop = {}

	local vs2010 = premake.vstudio.vs2010
	local vstudio = premake.vstudio
	local sln2005 = premake.vstudio.sln2005
	local solution = premake.solution
	local project = premake.project
	local config = premake.config
	local monodevelop = premake.extensions.monodevelop

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
		_p('\tEndGlobalSection')
	end


--
-- Patch some functions
--

	premake.override(sln2005, "solutionSections", function(oldfn, sln)
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

	premake.override(vstudio, "projectfile", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.iscpp(prj) then
				return project.getfilename(prj, ".cproj")
			end
		end
		return oldfn(prj)
	end)

	premake.override(vstudio, "tool", function(oldfn, prj)
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
		io.eol = "\r\n"
		io.esc = vs2010.esc

		if premake.project.isdotnet(prj) then
			premake.generate(prj, ".csproj", vstudio.cs2005.generate)
			premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user)
		elseif premake.project.iscpp(prj) then
			premake.generate(prj, ".cproj", monodevelop.generate)
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
			dotnet = { "msnet" },
		},

		-- Solution and project generation logic

		onsolution = vstudio.vs2005.generateSolution,
		onproject  = monodevelop.generateProject,

		oncleansolution = vstudio.cleanSolution,
		oncleanproject  = vstudio.cleanProject,
		oncleantarget   = vstudio.cleanTarget,

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
