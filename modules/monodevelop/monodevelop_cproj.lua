--
-- actions/vstudio/monodevelop_cproj.lua
-- Generate a MonoDevelop C/C++ cproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake
	local monodevelop = p.modules.monodevelop
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

	monodevelop.elements = {}

--
-- Generate a MonoDevelop C/C++ project.
--

	function monodevelop.generate(prj)
		monodevelop.header("Build")
		
		monodevelop.projectProperties(prj)

		for cfg in project.eachconfig(prj) do
			monodevelop.configurationProperties(cfg)
		end

		monodevelop.files(prj)
--		monodevelop.projectReferences(prj)

		_p('</Project>')
	end



--
-- Output the XML declaration and opening <Project> tag.
--

	function monodevelop.header(target)
		_p('<?xml version="1.0" encoding="utf-8"?>')

		local defaultTargets = ""
		if target then
			defaultTargets = string.format(' DefaultTargets="%s"', target)
		end

		_p('<Project%s ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', defaultTargets)
	end


--
-- Write out the project properties: what kind of binary it 
-- produces, and some global settings.
--

	function monodevelop.elements.projectProperties(prj)
		if project.iscpp(prj) then
			return {
				"productVersion",
				"schemaVersion",
				"projectGuid",
				"compiler",
				"language",
				"target",
				"version",
				"synchSlnVersion",
				"description",
			}
		end
	end

	function monodevelop.projectProperties(prj)
		_p(1,'<PropertyGroup>')

		_p(2,'<Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', 'Debug')
		_p(2,'<Platform Condition=" \'$(Platform)\' == \'\' ">%s</Platform>', 'AnyCPU')

		p.callarray(monodevelop.elements, monodevelop.elements.projectProperties(prj), prj)

		-- packages ...?

		_p(1,'</PropertyGroup>')
	end


--
-- Write out the configuration property group: what kind of binary it 
-- produces, and some global settings.
--

	function monodevelop.elements.configurationProperties(cfg)
		if project.iscpp(cfg.project) then
			return {
				"debuginfo",
				"outputPath",
				"outputName",
				"config_type",
				"preprocessorDefinitions",
				"sourceDirectory",
				"warnings",
				"optimization",
				"externalconsole",
				"additionalOptions",
				"additionalLinkOptions",
				"additionalIncludeDirectories",
				"additionalLibraryDirectories",
				"additionalDependencies",
				"buildEvents",
			}
		end
	end

	function monodevelop.configurationProperties(cfg)
		_p(1,'<PropertyGroup %s>', monodevelop.condition(cfg))
		p.callarray(monodevelop.elements, monodevelop.elements.configurationProperties(cfg), cfg)
		_p(1,'</PropertyGroup>')
	end


--
-- Format and return a MonoDevelop Condition attribute.
--

	function monodevelop.condition(cfg)
		return string.format('Condition=" \'$(Configuration)|$(Platform)\' == \'%s|AnyCPU\' "', p.esc(vstudio.projectPlatform(cfg)))
	end


--
-- Write out the list of source code files, and any associated configuration.
--

	function monodevelop.files(prj)
		monodevelop.filegroup(prj, "Include", "None")
		monodevelop.filegroup(prj, "Compile", "Compile")
		monodevelop.filegroup(prj, "Folder", "None")
		monodevelop.filegroup(prj, "None", "None")
		monodevelop.filegroup(prj, "ResourceCompile", "None")
		monodevelop.filegroup(prj, "CustomBuild", "None")
	end

	function monodevelop.filegroup(prj, group, action)
		local files = monodevelop.getfilegroup(prj, group)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				monodevelop.putfile(action, file)
			end
			_p(1,'</ItemGroup>')
		end
	end

	function monodevelop.putfile(action, file)
		local filename = file.relpath

		if not string.startswith(filename, '..') then
			_x(2,'<%s Include=\"%s\" />', action, path.translate(filename))
		else
			_x(2,'<%s Include=\"%s\">', action, path.translate(filename))

			-- Relative paths referring to parent directories need to use the special
			--   'Link' option to present them in the project hierarchy nicely
			while string.startswith(filename, '..') do
				filename = filename:sub(4)
			end
			_x(3,'<Link>%s</Link>', filename)

-- TODO: MonoDevelop really doesn't handle custom build tools very well (yet)
--			for cfg in project.eachconfig(prj) do
--				local condition = monodevelop.condition(cfg)					
--				local filecfg = config.getfileconfig(cfg, file.abspath)
--				if filecfg and filecfg.buildrule then
--					local commands = table.concat(filecfg.buildrule.commands,'\r\n')
--					_p(3,'<Generator %s>%s</Generator>', condition, p.esc(commands))
--				end
--			end

			_x(2,'</%s>', action)
		end
	end


	function monodevelop.getTargetGroup(node, prj, groups)
		-- if any configuration of this file uses a custom build rule,
		-- then they all must be marked as custom build
		local hasbuildrule = false
		for cfg in project.eachconfig(prj) do				
			local filecfg = fileconfig.getconfig(node, cfg)
			if filecfg and fileconfig.hasCustomBuildRule(filecfg) then
				hasbuildrule = true
				break
			end
		end

		if hasbuildrule then
			return groups.CustomBuild
		elseif path.iscppfile(node.name) then
			return groups.Compile
		elseif path.iscppheader(node.name) then
			return groups.Include
		elseif path.isresourcefile(node.name) then
			return groups.ResourceCompile
		else
			return groups.None
		end
	end


	function monodevelop.getfilegroup(prj, group)
		-- check for a cached copy before creating
		local groups = prj.monodevelop_file_groups
		if not groups then
			groups = {
				Compile = {},
				Include = {},
				Folder = {},
				None = {},
				ResourceCompile = {},
				CustomBuild = {},
			}
			prj.monodevelop_file_groups = groups

			local tr = project.getsourcetree(prj)
			tree.traverse(tr, {
				onleaf = function(node)
					table.insert(monodevelop.getTargetGroup(node, prj, groups), node)
				end
			})
		end

		return groups[group]
	end


--
-- Generate the list of project dependencies.
--

	function monodevelop.projectReferences(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			local prjpath = project.getlocation(prj)
			
			_p(1,'<ItemGroup>')
			for _, dep in ipairs(deps) do
				local relpath = path.getrelative(prjpath, vstudio.projectfile(dep))
				_x(2,'<ProjectReference Include=\"%s\">', path.translate(relpath))
				_p(3,'<Project>{%s}</Project>', dep.uuid)
				_p(2,'</ProjectReference>')
			end
			_p(1,'</ItemGroup>')
		end
	end


--
-- projectProperties element functions.
--

	function monodevelop.elements.productVersion(prj)
		local action = p.action.current()
		_p(2,'<ProductVersion>%s</ProductVersion>', action.vstudio.productVersion)
	end

	function monodevelop.elements.schemaVersion(prj)
		local action = p.action.current()
		_p(2,'<SchemaVersion>%s</SchemaVersion>', action.vstudio.csprojSchemaVersion)
	end

	function monodevelop.elements.projectGuid(prj)
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
	end

	function monodevelop.elements.compiler(prj)
		_p(2,'<Compiler>')
		_p(3,'<Compiler ctype="%s" />', iif(prj.language == 'C', 'GccCompiler', 'GppCompiler'))
		_p(2,'</Compiler>')
	end

	function monodevelop.elements.language(prj)
		_p(2,'<Language>%s</Language>', iif(prj.language == 'C', 'C', 'CPP'))
	end

	function monodevelop.elements.target(prj)
		_p(2,'<Target>%s</Target>', 'Bin')
	end

	function monodevelop.elements.version(prj)
		-- TODO: write a project version number into the project
--		_p(2,'<ReleaseVersion>%s</ReleaseVersion>', '0.1')
	end

	function monodevelop.elements.synchSlnVersion(prj)
		-- TODO: true = use solution version
--		_p(2,'<SynchReleaseVersion>%s</SynchReleaseVersion>', 'false')
	end

	function monodevelop.elements.description(prj)
		-- TODO: project description
--		_p(2,'<Description>%s</Description>', 'project description')
	end


--
-- configurationProperties element functions.
--

	function monodevelop.elements.debuginfo(cfg)
		if cfg.flags.Symbols then
			_p(2,'<DebugSymbols>%s</DebugSymbols>', iif(cfg.flags.Symbols, 'true', 'false'))
		end
	end

	function monodevelop.elements.outputPath(cfg)
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		_x(2,'<OutputPath>%s</OutputPath>', path.translate(outdir))
	end

	function monodevelop.elements.outputName(cfg)
		_x(2,'<OutputName>%s</OutputName>', cfg.buildtarget.name)
	end

	function monodevelop.elements.config_type(cfg)
		local map = {
			SharedLib = "SharedLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Bin",
			WindowedApp = "Bin"
		}
		_p(2,'<CompileTarget>%s</CompileTarget>', map[cfg.kind])
	end

	function monodevelop.elements.preprocessorDefinitions(cfg)
		local defines = cfg.defines
		if #defines > 0 then
			defines = table.concat(defines, ' ')
			_x(2,'<DefineSymbols>%s</DefineSymbols>', defines)
		end
	end

	function monodevelop.elements.sourceDirectory(cfg)
		_x(2,'<SourceDirectory>%s</SourceDirectory>', '.')
	end

	function monodevelop.elements.warnings(cfg)
		local map = { Off = "None", Extra = "All" }
		if cfg.warnings ~= nil and map[cfg.warnings] ~= nil then
			_p(2,'<WarningLevel>%s</WarningLevel>', map[cfg.warnings])
		end

		-- other warning blocks only when warnings are not disabled
		if cfg.warnings ~= "Off" and cfg.flags.FatalWarnings then
			_p(2,'<WarningsAsErrors>%s</WarningsAsErrors>', iif(cfg.flags.FatalWarnings, 'true', 'false'))
		end
	end

	function monodevelop.elements.optimization(cfg)
		-- TODO: 'size' should be Os, but this option just seems to be a numeric value
		local map = { Off = "0", On = "2", Debug = "0", Size = "2", Speed = "3", Full = "3" }
		if cfg.optimize ~= nil and map[cfg.optimize] then
			_p(2,'<OptimizationLevel>%s</OptimizationLevel>', map[cfg.optimize])
		end
	end

	function monodevelop.elements.externalconsole(cfg)
		_x(2,'<Externalconsole>%s</Externalconsole>', 'true')
	end

	function monodevelop.elements.additionalOptions(cfg)
		local opts = { }

		if cfg.project.language == 'C++' then
			if cfg.flags.NoExceptions then
				table.insert(opts, "-fno-exceptions")
			end
			if cfg.flags.NoRTTI then
				table.insert(opts, "-fno-rtti")
			end
		end

		-- TODO: Validate these flags are what is intended by these options...
--		if cfg.flags.FloatFast then
--			table.insert(opts, "-mno-ieee-fp")
--		elseif cfg.flags.FloatStrict then
--			table.insert(opts, "-mieee-fp")
--		end

		if cfg.vectorextensions == "SSE2" then
			table.insert(opts, "-msse2")
		elseif cfg.vectorextensions == "SSE" then
			table.insert(opts, "-msse")
		end

		local options
		if #opts > 0 then
			options = table.concat(opts, " ")
		end
		if #cfg.buildoptions > 0 then
			local buildOpts = table.concat(cfg.buildoptions, " ")
			options = iif(options, options .. " " .. buildOpts, buildOpts)
		end

		if options then
			_x(2,'<ExtraCompilerArguments>%s</ExtraCompilerArguments>', options)
		end
	end

	function monodevelop.elements.additionalLinkOptions(cfg)
		if #cfg.linkoptions > 0 then
			local opts = table.concat(cfg.linkoptions, " ")
			_x(2, '<ExtraLinkerArguments>%s</ExtraLinkerArguments>', opts)
		end
	end

	function monodevelop.elements.additionalIncludeDirectories(cfg)
		if #cfg.includedirs > 0 then
			_x(2,'<Includes>')
			_x(3,'<Includes>')

			for _, i in ipairs(cfg.includedirs) do
				_x(4,'<Include>%s</Include>', path.translate(i))
			end

			_x(3,'</Includes>')
			_x(2,'</Includes>')
		end
	end

	function monodevelop.elements.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			_x(2,'<LibPaths>')
			_x(3,'<LibPaths>')

			for _, l in ipairs(cfg.libdirs) do
				_x(4,'<LibPath>%s</LibPath>', path.translate(l))
			end

			_x(3,'</LibPaths>')
			_x(2,'</LibPaths>')
		end
	end

	function monodevelop.elements.additionalDependencies(cfg)
		local links

		-- check to see if this project uses an external toolset. If so, let the
		-- toolset define the format of the links
		local toolset = config.toolset(cfg)
		if toolset then
			links = toolset.getlinks(cfg, false)
		else
			-- VS always tries to link against project dependencies, even when those
			-- projects are excluded from the build. To work around, linking dependent
			-- projects is disabled, and sibling projects link explicitly
			links = config.getlinks(cfg, "all", "fullpath")
		end

		if #links > 0 then
			_x(2,'<Libs>')
			_x(3,'<Libs>')
			for _, lib in ipairs(links) do
				_x(4,'<Lib>%s</Lib>', path.translate(lib))
			end
			_x(3,'</Libs>')
			_x(2,'</Libs>')
		end
	end

	function monodevelop.elements.buildEvents(cfg)

		-- TODO: handle cfg.prelinkcommands...

		if #cfg.prebuildcommands > 0 or #cfg.postbuildcommands > 0 then
			_x(2,'<CustomCommands>')
			_x(3,'<CustomCommands>')

			for _, c in ipairs(cfg.prebuildcommands) do
				_x(4,'<Command type="BeforeBuild" command="%s" />', c)
			end

			for _, c in ipairs(cfg.postbuildcommands) do
				_x(4,'<Command type="AfterBuild" command="%s" />', c)
			end

			_x(3,'</CustomCommands>')
			_x(2,'</CustomCommands>')
		end
	end

