--
-- actions/vstudio/vs2013.lua
-- Extend the existing exporters with support for Visual Studio 2012.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local cs2005 = vstudio.cs2005
	local vc2010 = vstudio.vc2010


---
-- Define the Visual Studio 2013 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2013",
		shortname   = "Visual Studio 2013",
		description = "Generate Visual Studio 2013 project files",

		-- Visual Studio always uses Windows path and naming conventions

		os = "windows",

		-- temporary, until I can phase out the legacy implementations

		isnextgen = true,

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
			targetFramework = "4.5",
			toolsVersion    = "12.0",
		}
	}


---
-- Add new elements to the configuration properties block of C++ projects.
---

	table.insertafter(vc2010.elements.configurationProperties, "characterSet", "platformToolset")

	function vc2010.platformToolset(cfg)
		if _ACTION > "vs2012" then
			_p(2,'<PlatformToolset>v120</PlatformToolset>')
		end
	end


--
-- Add a common properties import statement to the top of C# projects.
--

	table.insertafter(cs2005.elements.project, "projectElement", "commonProperties")

	function cs2005.commonProperties(prj)
		if _ACTION > "vs2010" then
			_p(1,'<Import Project="$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props" Condition="Exists(\'$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props\')" />')
		end
	end
