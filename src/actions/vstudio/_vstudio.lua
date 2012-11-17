--
-- _vstudio.lua
-- Define the Visual Studio 200x actions.
-- Copyright (c) 2008-2012 Jason Perkins and the Premake project
--

	premake.vstudio = { }
	local vstudio = premake.vstudio
	local solution = premake.solution
	local project = premake5.project


--
-- The Visual Studio 2005 action, with support for the new platforms API
--

	newaction {
		trigger         = "vs2005ng",
		shortname       = "Visual Studio 2005 Next-gen",
		description     = "Experimental Microsoft Visual Studio 2005 project files",
		os              = "windows",

		-- temporary, until I can phase out the legacy implementations
		isnextgen = true,

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate_ng)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user_ng)
			end
		end,
		
		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}

--
-- The Visual Studio 2008 action, with support for the new platforms API
--

	newaction {
		trigger         = "vs2008ng",
		shortname       = "Visual Studio 2008 Next-gen",
		description     = "Experimental Microsoft Visual Studio 2008 project files",
		os              = "windows",

		-- temporary, until I can phase out the legacy implementations
		isnextgen = true,
		
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
		end,

		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate_ng)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user_ng)
			end
		end,

		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}

--
-- The Visual Studio 2010 action, with support for the new platforms API
--

	newaction {
		trigger         = "vs2010ng",
		shortname       = "Visual Studio 2010 Next-gen",
		description     = "Experimental Microsoft Visual Studio 2010 project files",
		os              = "windows",

		-- temporary, until I can phase out the legacy implementations
		isnextgen = true,

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
		end,

		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
			else
				premake.generate(prj, ".vcxproj", vstudio.vc2010.generate_ng)
				premake.generate(prj, ".vcxproj.user", vstudio.vc2010.generate_user_ng)
				premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generate_filters_ng)
			end
		end,

		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}


--
-- The Visual Studio 2012 action, with support for the new platforms API
--

	newaction {
		trigger         = "vs2012",
		shortname       = "Visual Studio 2012",
		description     = "Experimental Microsoft Visual Studio 2012 project files",
		os              = "windows",

		-- temporary, until I can phase out the legacy implementations
		isnextgen = true,

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate_ng)
		end,

		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate_ng)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user_ng)
			else
				premake.generate(prj, ".vcxproj", vstudio.vc2010.generate_ng)
				premake.generate(prj, ".vcxproj.user", vstudio.vc2010.generate_user_ng)
				premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generate_filters_ng)
			end
		end,

		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}


--
-- Mapping tables from Premake systems and architectures to Visual Studio
-- identifiers. Broken out as tables to new values can be pushed in by
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
		local iscpp = premake.iscppproject(cfg.project)

		local arch = architecture(cfg.system, cfg.architecture)			
		if not arch then
			arch = iif(iscpp, "x86", "Any CPU")
		end

		if win32 and iscpp and arch == "x86" then
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
		if prj.language == "C#" then
			extension = ".csproj"
		else
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
			local pltarch = vstudio.archFromPlatform(cfg.platform)
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
		local hascpp = false
		local hasnet = false
		local slnarch
		for prj in solution.eachproject_ng(cfg.solution) do
			if premake.iscppproject(prj) then
				hascpp = true
			elseif premake.isdotnetproject(prj) then
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
		elseif hasnet and hascpp then
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
		local hascpp = false
		local hasdotnet = false
		
		-- if the configuration has a platform identifier, use that as default
		local arch = cfg.platform
		
		-- if the platform identifier matches a known system or architecture,
		--
		
		for prj in solution.eachproject_ng(cfg.solution) do
			if premake.iscppproject(prj) then 
				hascpp = true
			elseif premake.isdotnetproject(prj) then
				hasdotnet = true
			end
			
			if hascpp and hasdotnet then
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
		arch = arch or iif(hascpp, "Win32", "Any CPU")
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




-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

--
-- Map Premake platform identifiers to the Visual Studio versions. Adds the Visual
-- Studio specific "any" and "mixed" to make solution generation easier.
--

	vstudio.platforms = { 
		any     = "Any CPU", 
		mixed   = "Mixed Platforms", 
		Native  = "Win32",
		x86     = "x86",
		x32     = "Win32", 
		x64     = "x64",
		PS3     = "PS3",
		Xbox360 = "Xbox 360",
	}

	

--
-- Returns the architecture identifier for a project.
-- Used by the solutions.
-- Deprecated, will be removed.
--

	function vstudio.arch(prj)
		if (prj.language == "C#") then
			if (_ACTION < "vs2005") then
				return ".NET"
			else
				return "Any CPU"
			end
		else
			return "Win32"
		end
	end


--
-- Process the solution's list of configurations and platforms, creates a list
-- of build configuration/platform pairs in a Visual Studio compatible format.
--

	function vstudio.buildconfigs(sln)
		local cfgs = { }
		
		local platforms = premake.filterplatforms(sln, vstudio.platforms, "Native")

		-- Figure out what's in this solution
		local hascpp    = premake.hascppproject(sln)
		local hasdotnet = premake.hasdotnetproject(sln)

		-- "Mixed Platform" solutions are generally those containing both
		-- C/C++ and .NET projects. Starting in VS2010, all .NET solutions
		-- also contain the Mixed Platform option.
		if hasdotnet and (_ACTION > "vs2008" or hascpp) then
			table.insert(platforms, 1, "mixed")
		end
		
		-- "Any CPU" is added to solutions with .NET projects. Starting in
		-- VS2010, only pure .NET solutions get this option.
		if hasdotnet and (_ACTION < "vs2010" or not hascpp) then
			table.insert(platforms, 1, "any")
		end

		-- In Visual Studio 2010, pure .NET solutions replace the Win32 platform
		-- with x86. In mixed mode solution, x86 is used in addition to Win32.
		if _ACTION > "vs2008" then
			local platforms2010 = { }
			for _, platform in ipairs(platforms) do
				if vstudio.platforms[platform] == "Win32" then
					if hascpp then
						table.insert(platforms2010, platform)
					end
					if hasdotnet then
						table.insert(platforms2010, "x86")
					end
				else
					table.insert(platforms2010, platform)
				end
			end
			platforms = platforms2010
		end


		for _, buildcfg in ipairs(sln.configurations) do
			for _, platform in ipairs(platforms) do
				local entry = { }
				entry.src_buildcfg = buildcfg
				entry.src_platform = platform
				
				-- PS3 is funky and needs special handling; it's more of a build
				-- configuration than a platform from Visual Studio's point of view				
				if platform ~= "PS3" then
					entry.buildcfg = buildcfg
					entry.platform = vstudio.platforms[platform]
				else
					entry.buildcfg = platform .. " " .. buildcfg
					entry.platform = "Win32"
				end

				-- create a name the way VS likes it
				entry.name = entry.buildcfg .. "|" .. entry.platform
				
				-- flag the "fake" platforms added for .NET
				entry.isreal = (platform ~= "any" and platform ~= "mixed")
								
				table.insert(cfgs, entry)
			end
		end
		
		return cfgs
	end
	


--
-- Clean Visual Studio files
--

	function vstudio.cleansolution(sln)
		premake.clean.file(sln, "%%.sln")
		premake.clean.file(sln, "%%.suo")
		premake.clean.file(sln, "%%.ncb")
		-- MonoDevelop files
		premake.clean.file(sln, "%%.userprefs")
		premake.clean.file(sln, "%%.usertasks")
	end
	
	function vstudio.cleanproject(prj)
		local fname = project.getfilename(prj)

		os.remove(fname .. ".vcproj")
		os.remove(fname .. ".vcproj.user")

		os.remove(fname .. ".vcxproj")
		os.remove(fname .. ".vcxproj.user")
		os.remove(fname .. ".vcxproj.filters")

		os.remove(fname .. ".csproj")
		os.remove(fname .. ".csproj.user")

		os.remove(fname .. ".pidb")
		os.remove(fname .. ".sdf")
	end

	function vstudio.cleantarget(name)
		os.remove(name .. ".pdb")
		os.remove(name .. ".idb")
		os.remove(name .. ".ilk")
		os.remove(name .. ".vshost.exe")
		os.remove(name .. ".exe.manifest")
	end
	
	

--
-- Assemble the project file name.
--

	function vstudio.projectfile_old(prj)
		local extension
		if prj.language == "C#" then
			extension = ".csproj"
		else
			extension = iif(_ACTION > "vs2008", ".vcxproj", ".vcproj")
		end

		local fname = path.join(prj.location, prj.name)
		return fname..extension
	end
	

--
-- Returns the Visual Studio tool ID for a given project type.
--

	function vstudio.tool(prj)
		if (prj.language == "C#") then
			return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC"
		else
			return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942"
		end
	end


--
-- Register Visual Studio 2002
--

	newaction {
		trigger         = "vs2002",
		shortname       = "Visual Studio 2002",
		description     = "Generate Microsoft Visual Studio 2002 project files",
		os              = "windows",
		
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2002.generate)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2002.generate)
				premake.generate(prj, ".csproj.user", vstudio.cs2002.generate_user)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user)
			end
		end,
		
		oncleansolution = premake.vstudio.cleansolution,
		oncleanproject  = premake.vstudio.cleanproject,
		oncleantarget   = premake.vstudio.cleantarget
	}


--
-- Register Visual Studio 2003
--

	newaction {
		trigger         = "vs2003",
		shortname       = "Visual Studio 2003",
		description     = "Generate Microsoft Visual Studio 2003 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2003.generate)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2002.generate)
				premake.generate(prj, ".csproj.user", vstudio.cs2002.generate_user)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user)
			end
		end,
		
		oncleansolution = premake.vstudio.cleansolution,
		oncleanproject  = premake.vstudio.cleanproject,
		oncleantarget   = premake.vstudio.cleantarget
	}


--
-- Register Visual Studio 2005
--

	newaction {
		trigger         = "vs2005",
		shortname       = "Visual Studio 2005",
		description     = "Generate Microsoft Visual Studio 2005 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user)
			end
		end,
		
		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}


--
-- Register Visual Studio 2008
--

	newaction {
		trigger         = "vs2008",
		shortname       = "Visual Studio 2008",
		description     = "Generate Microsoft Visual Studio 2008 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user)
			else
				premake.generate(prj, ".vcproj", vstudio.vc200x.generate)
				premake.generate(prj, ".vcproj.user", vstudio.vc200x.generate_user)
			end
		end,
		
		oncleansolution = vstudio.cleansolution,
		oncleanproject  = vstudio.cleanproject,
		oncleantarget   = vstudio.cleantarget
	}

		
--
-- Register Visual Studio 2010
--

	newaction 
	{
		trigger         = "vs2010",
		shortname       = "Visual Studio 2010",
		description     = "Generate Visual Studio 2010 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#"},
		
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			premake.generate(sln, ".sln", vstudio.sln2005.generate)
		end,
		
		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, ".csproj", vstudio.cs2005.generate)
				premake.generate(prj, ".csproj.user", vstudio.cs2005.generate_user)
			else
			premake.generate(prj, ".vcxproj", premake.vs2010_vcxproj)
			premake.generate(prj, ".vcxproj.user", premake.vs2010_vcxproj_user)
			premake.generate(prj, ".vcxproj.filters", vstudio.vc2010.generate_filters)
			end
		end,
		

		oncleansolution = premake.vstudio.cleansolution,
		oncleanproject  = premake.vstudio.cleanproject,
		oncleantarget   = premake.vstudio.cleantarget
	}
