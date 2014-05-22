--
-- actions/vstudio/vs2013.lua
-- Extend the existing exporters with support for Visual Studio 2013.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	premake.vstudio.vc2013 = {}

	local p = premake
	local vstudio = p.vstudio
	local vc2010 = vstudio.vc2010

	local m = vstudio.vc2013


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
			versionName     = "2013",
			targetFramework = "4.5",
			toolsVersion    = "12.0",
		}
	}


---
-- VS 2013 warns on duplicate file names, even those files are contained in
-- different, mututally exclusive configurations. See:
-- http://connect.microsoft.com/VisualStudio/feedback/details/797460/incorrect-warning-msb8027-reported-for-files-excluded-from-build
--
-- Premake already adds unique object names to conflicting file names, so just
-- go ahead and disable that warning.
---

	premake.override(vc2010.elements, "globals", function(base, prj)
		local calls = base(prj)
		table.insertafter(calls, vc2010.projectGuid, m.ignoreWarnDuplicateFilename)
		return calls
	end)

	function m.ignoreWarnDuplicateFilename(prj)
		if _ACTION > "vs2012" then
			p.w('<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>')
		end
	end



---
-- Add new elements to the configuration properties block of C++ projects.
---

	premake.override(vc2010, "platformToolset", function(base, cfg)
		if _ACTION > "vs2012" then
			_p(2,'<PlatformToolset>v120</PlatformToolset>')
		else
			base(cfg)
		end
	end)
