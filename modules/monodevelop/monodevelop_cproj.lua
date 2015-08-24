--
-- monodevelop/monodevelop_cproj.lua
-- Generate a MonoDevelop C/C++ cproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake
	local m = p.modules.monodevelop

	m.cproj = {}

	local vstudio = p.vstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

--
-- Generate a MonoDevelop C/C++ project.
--

	function m.generate(prj)
		m.header("Build")
		
		m.projectProperties(prj)

		for cfg in project.eachconfig(prj) do
			m.configurationProperties(cfg)
		end

		m.files(prj)
--		m.projectReferences(prj)

		_p('</Project>')
	end



--
-- Output the XML declaration and opening <Project> tag.
--

	function m.header(target)
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

	m.elements.projectProperties = function(prj)
		if project.iscpp(prj) then
			return {
				m.cproj.productVersion,
				m.cproj.schemaVersion,
				m.cproj.projectGuid,
				m.cproj.compiler,
				m.cproj.language,
				m.cproj.target,
				m.cproj.version,
				m.cproj.synchSlnVersion,
				m.cproj.description,
			}
		end
	end

	function m.projectProperties(prj)
		_p(1,'<PropertyGroup>')

		_p(2,'<Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', 'Debug')
		_p(2,'<Platform Condition=" \'$(Platform)\' == \'\' ">%s</Platform>', 'AnyCPU')

		p.callArray(m.elements.projectProperties, prj)

		-- packages ...?

		_p(1,'</PropertyGroup>')
	end


--
-- Write out the configuration property group: what kind of binary it 
-- produces, and some global settings.
--

	m.elements.configurationProperties = function(cfg)
		if project.iscpp(cfg.project) then
			return {
				m.cproj.debuginfo,
				m.cproj.outputPath,
				m.cproj.outputName,
				m.cproj.config_type,
				m.cproj.preprocessorDefinitions,
				m.cproj.sourceDirectory,
				m.cproj.warnings,
				m.cproj.optimization,
				m.cproj.externalconsole,
				m.cproj.additionalOptions,
				m.cproj.additionalLinkOptions,
				m.cproj.additionalIncludeDirectories,
				m.cproj.additionalLibraryDirectories,
				m.cproj.additionalDependencies,
				m.cproj.buildEvents,
			}
		end
	end

	function m.configurationProperties(cfg)
		_p(1,'<PropertyGroup %s>', m.condition(cfg))
		p.callArray(m.elements.configurationProperties, cfg)
		_p(1,'</PropertyGroup>')
	end


--
-- Format and return a MonoDevelop Condition attribute.
--

	function m.condition(cfg)
		return string.format('Condition=" \'$(Configuration)|$(Platform)\' == \'%s|AnyCPU\' "', p.esc(vstudio.projectPlatform(cfg)))
	end


--
-- Write out the list of source code files, and any associated configuration.
--

	function m.files(prj)
		m.filegroup(prj, "Include", "None")
		m.filegroup(prj, "Compile", "Compile")
		m.filegroup(prj, "Folder", "None")
		m.filegroup(prj, "None", "None")
		m.filegroup(prj, "ResourceCompile", "None")
		m.filegroup(prj, "CustomBuild", "None")
	end

	function m.filegroup(prj, group, action)
		local files = m.getfilegroup(prj, group)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				m.putfile(action, file)
			end
			_p(1,'</ItemGroup>')
		end
	end

	function m.putfile(action, file)
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
--				local condition = m.condition(cfg)					
--				local filecfg = config.getfileconfig(cfg, file.abspath)
--				if filecfg and filecfg.buildrule then
--					local commands = table.concat(filecfg.buildrule.commands,'\r\n')
--					_p(3,'<Generator %s>%s</Generator>', condition, p.esc(commands))
--				end
--			end

			_x(2,'</%s>', action)
		end
	end


	function m.getTargetGroup(node, prj, groups)
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


	function m.getfilegroup(prj, group)
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
					table.insert(m.getTargetGroup(node, prj, groups), node)
				end
			})
		end

		return groups[group]
	end


--
-- Generate the list of project dependencies.
--

	function m.projectReferences(prj)
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

	function m.cproj.productVersion(prj)
		local action = p.action.current()
		_p(2,'<ProductVersion>%s</ProductVersion>', action.vstudio.productVersion)
	end

	function m.cproj.schemaVersion(prj)
		local action = p.action.current()
		_p(2,'<SchemaVersion>%s</SchemaVersion>', action.vstudio.csprojSchemaVersion)
	end

	function m.cproj.projectGuid(prj)
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
	end

	function m.cproj.compiler(prj)
		_p(2,'<Compiler>')
		_p(3,'<Compiler ctype="%s" />', iif(prj.language == 'C', 'GccCompiler', 'GppCompiler'))
		_p(2,'</Compiler>')
	end

	function m.cproj.language(prj)
		_p(2,'<Language>%s</Language>', iif(prj.language == 'C', 'C', 'CPP'))
	end

	function m.cproj.target(prj)
		_p(2,'<Target>%s</Target>', 'Bin')
	end

	function m.cproj.version(prj)
		-- TODO: write a project version number into the project
--		_p(2,'<ReleaseVersion>%s</ReleaseVersion>', '0.1')
	end

	function m.cproj.synchSlnVersion(prj)
		-- TODO: true = use solution version
--		_p(2,'<SynchReleaseVersion>%s</SynchReleaseVersion>', 'false')
	end

	function m.cproj.description(prj)
		-- TODO: project description
--		_p(2,'<Description>%s</Description>', 'project description')
	end


--
-- configurationProperties element functions.
--

	function m.cproj.debuginfo(cfg)
		if cfg.flags.Symbols then
			_p(2,'<DebugSymbols>%s</DebugSymbols>', iif(cfg.flags.Symbols, 'true', 'false'))
		end
	end

	function m.cproj.outputPath(cfg)
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		_x(2,'<OutputPath>%s</OutputPath>', path.translate(outdir))
	end

	function m.cproj.outputName(cfg)
		_x(2,'<OutputName>%s</OutputName>', cfg.buildtarget.name)
	end

	function m.cproj.config_type(cfg)
		local map = {
			SharedLib = "SharedLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Bin",
			WindowedApp = "Bin"
		}
		_p(2,'<CompileTarget>%s</CompileTarget>', map[cfg.kind])
	end

	function m.cproj.preprocessorDefinitions(cfg)
		local defines = cfg.defines
		if #defines > 0 then
			defines = table.concat(defines, ' ')
			_x(2,'<DefineSymbols>%s</DefineSymbols>', defines)
		end
	end

	function m.cproj.sourceDirectory(cfg)
		_x(2,'<SourceDirectory>%s</SourceDirectory>', '.')
	end

	function m.cproj.warnings(cfg)
		local map = { Off = "None", Extra = "All" }
		if cfg.warnings ~= nil and map[cfg.warnings] ~= nil then
			_p(2,'<WarningLevel>%s</WarningLevel>', map[cfg.warnings])
		end

		-- other warning blocks only when warnings are not disabled
		if cfg.warnings ~= "Off" and cfg.flags.FatalCompileWarnings then
			_p(2,'<WarningsAsErrors>%s</WarningsAsErrors>', iif(cfg.flags.FatalCompileWarnings, 'true', 'false'))
		end
	end

	function m.cproj.optimization(cfg)
		-- TODO: 'size' should be Os, but this option just seems to be a numeric value
		local map = { Off = "0", On = "2", Debug = "0", Size = "2", Speed = "3", Full = "3" }
		if cfg.optimize ~= nil and map[cfg.optimize] then
			_p(2,'<OptimizationLevel>%s</OptimizationLevel>', map[cfg.optimize])
		end
	end

	function m.cproj.externalconsole(cfg)
		_x(2,'<Externalconsole>%s</Externalconsole>', 'true')
	end

	function m.cproj.additionalOptions(cfg)
		local opts = { }

		if cfg.project.language == 'C++' then
			if cfg.exceptionhandling == p.OFF then
				table.insert(opts, "-fno-exceptions")
			end
			if cfg.rtti == p.OFF then
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
			if options then
				options = options .. " " .. buildOpts
			else
				options = buildOpts
			end
		end

		if options then
			_x(2,'<ExtraCompilerArguments>%s</ExtraCompilerArguments>', options)
		end
	end

	function m.cproj.additionalLinkOptions(cfg)
		if #cfg.linkoptions > 0 then
			local opts = table.concat(cfg.linkoptions, " ")
			_x(2, '<ExtraLinkerArguments>%s</ExtraLinkerArguments>', opts)
		end
	end

	function m.cproj.additionalIncludeDirectories(cfg)
		if #cfg.includedirs > 0 then
			_x(2,'<Includes>')
			_x(3,'<Includes>')

			for _, i in ipairs(project.getrelative(cfg.project, cfg.includedirs)) do
				_x(4,'<Include>%s</Include>', path.translate(i))
			end

			_x(3,'</Includes>')
			_x(2,'</Includes>')
		end
	end

	function m.cproj.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			_x(2,'<LibPaths>')
			_x(3,'<LibPaths>')

			for _, l in ipairs(project.getrelative(cfg.project, cfg.libdirs)) do
				_x(4,'<LibPath>%s</LibPath>', path.translate(l))
			end

			_x(3,'</LibPaths>')
			_x(2,'</LibPaths>')
		end
	end

	function m.cproj.additionalDependencies(cfg)
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

	function m.cproj.buildEvents(cfg)

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

