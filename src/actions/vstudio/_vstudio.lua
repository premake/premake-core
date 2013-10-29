--
-- _vstudio.lua
-- Define the Visual Studio 200x actions.
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--

	premake.vstudio = {}
	local vstudio = premake.vstudio
	local solution = premake.solution
	local project = premake.project
	local config = premake.config


--
-- Mapping tables from Premake systems and architectures to Visual Studio
-- identifiers. Broken out as tables so new values can be pushed in by
-- add-ons.
--

	vstudio.vs200x_architectures =
	{
		x32     = "x86",
		x64     = "x64",
		xbox360 = "Xbox 360",
	}

	vstudio.vs2010_architectures =
	{
	}


	local function architecture(system, arch)
		local result
		if _ACTION >= "vs2010" then
			result = vstudio.vs2010_architectures[arch] or vstudio.vs2010_architectures[system]
		end
		return result or vstudio.vs200x_architectures[arch] or vstudio.vs200x_architectures[system]
	end


--
-- Translate the system and architecture settings from a configuration
-- into a corresponding Visual Studio identifier. If no settings are
-- found in the configuration, a default value is returned, based on
-- the project settings.
--
-- @param cfg
--    The configuration to translate.
-- @param win32
--    If true, enables the "Win32" symbol. If false, uses "x86" instead.
-- @return
--    A Visual Studio architecture identifier.
--

	function vstudio.archFromConfig(cfg, win32)
		local isnative = project.isnative(cfg.project)

		local arch = architecture(cfg.system, cfg.architecture)
		if not arch then
			arch = iif(isnative, "x86", "Any CPU")
		end

		if win32 and isnative and arch == "x86" then
			arch = "Win32"
		end

		return arch
	end


--
-- Attempt to translate a platform identifier into a corresponding
-- Visual Studio architecture identifier.
--
-- @param platform
--    The platform identifier to translate.
-- @return
--    A Visual Studio architecture identifier, or nil if no mapping
--    could be made.
--

	function vstudio.archFromPlatform(platform)
		local system = premake.api.checkvalue(platform, premake.fields.system)
		local arch = premake.api.checkvalue(platform, premake.fields.architecture)
		return architecture(system, arch)
	end


--
-- Return true if the configuration kind is one of "Makefile" or "None". The
-- latter is generated like a Makefile project and excluded from the solution.
--

	function vstudio.isMakefile(cfg)
		return (cfg.kind == premake.MAKEFILE or cfg.kind == premake.NONE)
	end


--
-- If a dependency of a project configuration is excluded from that particular
-- build configuration or platform, Visual Studio will still try to link it.
-- This function detects that case, so that the individual actions can work
-- around it by switching to external linking.
--
-- @param cfg
--    The configuration to test.
-- @return
--    True if the configuration excludes one or more dependencies.
--

	function vstudio.needsExplicitLink(cfg)
		local ex = cfg.flags.NoImplicitLink
		if not ex then
			local prjdeps = project.getdependencies(cfg.project)
			local cfgdeps = config.getlinks(cfg, "dependencies", "object")
			ex = #prjdeps ~= #cfgdeps
		end
		return ex
	end


--
-- Returns the Visual Studio project configuration identifier corresponding
-- to the given Premake configuration.
--
-- @param cfg
--    The configuration to query.
-- @param arch
--    An optional architecture identifier, to override the configuration.
-- @return
--    A project configuration identifier of the form
--    <project platform name>|<architecture>.
--

	function vstudio.projectConfig(cfg, arch)
		local platform = vstudio.projectPlatform(cfg)
		local architecture = arch or vstudio.archFromConfig(cfg, true)
		return platform .. "|" .. architecture
	end


--
-- Returns the full, absolute path to the Visual Studio project file
-- corresponding to a particular project object.
--
-- @param prj
--    The project object.
-- @return
--    The absolute path to the corresponding Visual Studio project file.
--

	function vstudio.projectfile(prj)
		local extension
		if project.isdotnet(prj) then
			extension = ".csproj"
		elseif project.iscpp(prj) then
			extension = iif(_ACTION > "vs2008", ".vcxproj", ".vcproj")
		end

		return project.getfilename(prj, extension)
	end


--
-- Returns a project configuration name corresponding to the given
-- Premake configuration. This is just the solution build configuration
-- and platform identifiers concatenated.
--

	function vstudio.projectPlatform(cfg)
		local platform = cfg.platform
		if platform then
			local pltarch = vstudio.archFromPlatform(cfg.platform) or platform
			local cfgarch = vstudio.archFromConfig(cfg)
			if pltarch == cfgarch then
				platform = nil
			end
		end

		if platform then
			return cfg.buildcfg .. " " .. platform
		else
			return cfg.buildcfg
		end
	end


--
-- Determine the appropriate Visual Studio platform identifier for a
-- solution-level configuration.
--
-- @param cfg
--    The configuration to be identified.
-- @return
--    A corresponding Visual Studio platform identifier.
--

	function vstudio.solutionPlatform(cfg)
		local platform = cfg.platform

		-- if a platform is specified use it, translating to the corresponding
		-- Visual Studio identifier if appropriate
		local platarch
		if platform then
			platform = vstudio.archFromPlatform(platform) or platform

			-- Value for 32-bit arch is different depending on whether this solution
			-- contains C++ or C# projects or both
			if platform ~= "x86" then
				return platform
			end
		end

		-- scan the contained projects to identify the platform
		local hasnative = false
		local hasnet = false
		local slnarch
		for prj in solution.eachproject(cfg.solution) do
			if project.isnative(prj) then
				hasnative = true
			elseif project.isdotnet(prj) then
				hasnet = true
			end

			-- get a VS architecture identifier for this project
			local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
			if prjcfg then
				local prjarch = vstudio.archFromConfig(prjcfg)
				if not slnarch then
					slnarch = prjarch
				elseif slnarch ~= prjarch then
					slnarch = "Mixed Platforms"
				end
			end
		end


		if platform then
			return iif(hasnet, "x86", "Win32")
		elseif slnarch then
			return iif(slnarch == "x86" and not hasnet, "Win32", slnarch)
		elseif hasnet and hasnative then
			return "Mixed Platforms"
		elseif hasnet then
			return "Any CPU"
		else
			return "Win32"
		end
	end


--
-- Attempt to determine an appropriate Visual Studio architecture identifier
-- for a solution configuration.
--
-- @param cfg
--    The configuration to query.
-- @return
--    A best guess at the corresponding Visual Studio architecture identifier.
--

	function vstudio.solutionarch(cfg)
		local hasnative = false
		local hasdotnet = false

		-- if the configuration has a platform identifier, use that as default
		local arch = cfg.platform

		-- if the platform identifier matches a known system or architecture,
		--

		for prj in solution.eachproject(cfg.solution) do
			if project.isnative(prj) then
				hasnative = true
			elseif project.isdotnet(prj) then
				hasdotnet = true
			end

			if hasnative and hasdotnet then
				return "Mixed Platforms"
			end

			if not arch then
				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg then
					if prjcfg.architecture then
						arch = vstudio.archFromConfig(prjcfg)
					end
				end
			end
		end

		-- use a default if no other architecture was specified
		arch = arch or iif(hasnative, "Win32", "Any CPU")
		return arch
	end


--
-- Returns the Visual Studio solution configuration identifier corresponding
-- to the given Premake configuration.
--
-- @param cfg
--    The configuration to query.
-- @return
--    A solution configuration identifier of the format BuildCfg|Platform,
--    corresponding to the Premake values of the same names. If no platform
--    was specified by the script, the architecture is used instead.
--

	function vstudio.solutionconfig(cfg)
		local platform = cfg.platform

		-- if no platform name was specified, use the architecture instead;
		-- since architectures are defined in the projects and not at the
		-- solution level, need to poke around to figure this out
		if not platform then
			platform = vstudio.solutionarch(cfg)
		end

		return string.format("%s|%s", cfg.buildcfg, platform)
	end


--
-- Returns the Visual Studio tool ID for a given project type.
--

	function vstudio.tool(prj)
		if project.isdotnet(prj) then
			return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC"
		elseif project.iscpp(prj) then
			return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942"
		end
	end

