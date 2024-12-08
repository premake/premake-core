--
-- vs2010.lua
-- Add support for the Visual Studio 2010 project formats.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vs2010 = {}

	local vs2010 = p.vstudio.vs2010
	local vstudio = p.vstudio
	local project = p.project
	local tree = p.tree


---
-- Map Premake tokens to the corresponding Visual Studio variables.
---

	vs2010.pathVars = {
		["cfg.objdir"]                  = { absolute = true,  token = "$(IntDir)" },
		["prj.location"]                = { absolute = true,  token = "$(ProjectDir)" },
		["prj.name"]                    = { absolute = false, token = "$(ProjectName)" },
		["sln.location"]                = { absolute = true,  token = "$(SolutionDir)" },
		["sln.name"]                    = { absolute = false, token = "$(SolutionName)" },
		["wks.location"]                = { absolute = true,  token = "$(SolutionDir)" },
		["wks.name"]                    = { absolute = false, token = "$(SolutionName)" },
		["cfg.buildtarget.directory"]   = { absolute = false, token = "$(TargetDir)" },
		["cfg.buildtarget.name"]        = { absolute = false, token = "$(TargetFileName)" },
		["cfg.buildtarget.basename"]    = { absolute = false, token = "$(TargetName)" },
		["file.basename"]               = { absolute = false, token = "%(Filename)" },
		["file.abspath"]                = { absolute = true,  token = "%(FullPath)" },
		["file.relpath"]                = { absolute = false, token = "%(Identity)" },
		["file.path"]                   = { absolute = false, token = "%(Identity)" },
		["file.directory"]              = { absolute = true,  token = "%(RootDir)%(Directory)" },
		["file.reldirectory"]           = { absolute = false, token = "%(RelativeDir)" },
		["file.extension"]              = { absolute = false, token = "%(Extension)" },
		["file.name"]                   = { absolute = false, token = "%(Filename)%(Extension)" },
		["file.ruleinputs"]            	= { absolute = false, token = "[Inputs]" },
	}



---
-- Identify the type of project being exported and hand it off
-- the right generator.
---

	function vs2010.generateProject(prj)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(vs2010.esc)

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

		elseif p.project.isc(prj) or p.project.iscpp(prj) then
			if prj.kind == p.SHAREDITEMS then
				local projFileModified = p.generate(prj, ".vcxitems", vstudio.vc2013.generate)

				-- Only generate a filters file if the source tree actually has subfolders
				if tree.hasbranches(project.getsourcetree(prj)) then
					if p.generate(prj, ".vcxitems.filters", vstudio.vc2010.generateFilters) == true and projFileModified == false then
						-- vs workaround for issue where if only the .filters file is modified, VS doesn't automaticly trigger a reload
						p.touch(prj, ".vcxitems")
					end
				end

			elseif prj.kind == p.PACKAGING then

				if project.iscpp(prj) then
					p.generate(prj, ".androidproj", vstudio.androidproj.generate)
				
					-- Skip generation of empty user files
					local user = p.capture(function() vstudio.vc2010.generateUser(prj) end)
					if #user > 0 then
						p.generate(prj, ".androidproj.user", function() p.outln(user) end)
					end
				end

			else
				local projFileModified = p.generate(prj, ".vcxproj", vstudio.vc2010.generate)

				-- Skip generation of empty user files
				local user = p.capture(function() vstudio.vc2010.generateUser(prj) end)
				if #user > 0 then
					p.generate(prj, ".vcxproj.user", function() p.outln(user) end)
				end

				-- Only generate a filters file if the source tree actually has subfolders
				if tree.hasbranches(project.getsourcetree(prj)) then
					if p.generate(prj, ".vcxproj.filters", vstudio.vc2010.generateFilters) == true and projFileModified == false then
						-- vs workaround for issue where if only the .filters file is modified, VS doesn't automaticly trigger a reload
						p.touch(prj, ".vcxproj")
					end
				end
			end
		end

		if not vstudio.nuget2010.supportsPackageReferences(prj) then
			-- Skip generation of empty packages.config files
			local packages = p.capture(function() vstudio.nuget2010.generatePackagesConfig(prj) end)
			if #packages > 0 then
				p.generate(prj, "packages.config", function() p.outln(packages) end)
			end

			-- Skip generation of empty NuGet.Config files
			local config = p.capture(function() vstudio.nuget2010.generateNuGetConfig(prj) end)
			if #config > 0 then
				p.generate(prj, "NuGet.Config", function() p.outln(config) end)
			end
		end
	end



---
-- Generate the .props, .targets, and .xml files for custom rules.
---

	function vs2010.generateRule(rule)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(vs2010.esc)

		p.generate(rule, ".props", vs2010.rules.props.generate)
		p.generate(rule, ".targets", vs2010.rules.targets.generate)
		p.generate(rule, ".xml", vs2010.rules.xml.generate)
	end



--
-- The VS 2010 standard for XML escaping in generated project files.
--

	function vs2010.esc(value)
		value = value:gsub('&',  "&amp;")
		value = value:gsub('<',  "&lt;")
		value = value:gsub('>',  "&gt;")
		return value
	end



---
-- Define the Visual Studio 2010 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2010",
		shortname   = "Visual Studio 2010",
		description = "Generate Visual Studio 2010 project files",

		-- Visual Studio always uses Windows path and naming conventions

		targetos = "windows",
		toolset  = "msc-v100",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None", "Utility" },
		valid_languages = { "C", "C++", "C#", "F#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onWorkspace = function(wks)
			vstudio.vs2005.generateSolution(wks)
		end,
		onProject = function(prj)
			vstudio.vs2010.generateProject(prj)
		end,
		onRule = function(rule)
			vstudio.vs2010.generateRule(rule)
		end,

		onCleanWorkspace = function(wks)
			vstudio.cleanSolution(wks)
		end,
		onCleanProject = function(prj)
			vstudio.cleanProject(prj)
		end,
		onCleanTarget = function(prj)
			vstudio.cleanTarget(prj)
		end,

		pathVars        = vs2010.pathVars,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			csprojSchemaVersion = "2.0",
			productVersion      = "8.0.30703",
			solutionVersion     = "11",
			versionName         = "2010",
			targetFramework     = "4.0",
			toolsVersion        = "4.0",
		}
	}
