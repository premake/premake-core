--
-- vs2005.lua
-- Add support for the  Visual Studio 2005 project formats.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vs2005 = {}

	local vs2005 = p.vstudio.vs2005
	local vstudio = p.vstudio


---
-- Register a command-line action for Visual Studio 2006.
---

	function vs2005.generateSolution(wks)
		p.indent("\t")
		p.eol("\r\n")
		p.escaper(vs2005.esc)

		p.generate(wks, ".sln", vstudio.sln2005.generate)
	end


	function vs2005.generateProject(prj)
		p.indent("  ")
		p.eol("\r\n")
		p.escaper(vs2005.esc)

		if p.project.iscsharp(prj) then
			p.generate(prj, ".csproj", vstudio.cs2005.generate)

			-- Skip generation of empty user files
			local user = p.capture(function() vstudio.cs2005.generateUser(prj) end)
			if #user > 0 then
				p.generate(prj, ".csproj.user", function() p.outln(user) end)
			end
		elseif p.project.isfsharp(prj) then
			p.generate(prj, ".fsproj", vstudio.fs2005.generate)

			-- Skip generation of empty user files
			local user = p.capture(function() vstudio.fs2005.generateUser(prj) end)
			if #user > 0 then
				p.generate(prj, ".fsproj.user", function() p.outln(user) end)
			end
		else
			p.generate(prj, ".vcproj", vstudio.vc200x.generate)

			-- Skip generation of empty user files
			local user = p.capture(function() vstudio.vc200x.generateUser(prj) end)
			if #user > 0 then
				p.generate(prj, ".vcproj.user", function() p.outln(user) end)
			end
		end
	end



---
-- Apply XML escaping on a value to be included in an
-- exported project file.
---

	function vs2005.esc(value)
		value = string.gsub(value, '&',  "&amp;")
		value = value:gsub('"',  "&quot;")
		value = value:gsub("'",  "&apos;")
		value = value:gsub('<',  "&lt;")
		value = value:gsub('>',  "&gt;")
		value = value:gsub('\r', "&#x0D;")
		value = value:gsub('\n', "&#x0A;")
		return value
	end



---
-- Define the Visual Studio 2005 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2005",
		shortname   = "Visual Studio 2005",
		description = "Generate Visual Studio 2005 project files",

		-- Visual Studio always uses Windows path and naming conventions

		targetos = "windows",
		toolset  = "msc-v80",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None" },
		valid_languages = { "C", "C++", "C#", "F#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = vstudio.vs2005.generateSolution,
		onProject   = vstudio.vs2005.generateProject,

		onCleanWorkspace = vstudio.cleanSolution,
		onCleanProject   = vstudio.cleanProject,
		onCleanTarget    = vstudio.cleanTarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "8.0.50727",
			solutionVersion     = "9",
			versionName         = "2005",
		}
	}
