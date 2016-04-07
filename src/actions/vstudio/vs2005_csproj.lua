--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005-2010 C# project.
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	premake.vstudio.cs2005 = {}

	local p = premake
	local vstudio = p.vstudio
	local cs2005  = p.vstudio.cs2005
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local dotnet = p.tools.dotnet


	cs2005.elements = {}


--
-- Generate a Visual Studio 200x C# project, with support for the new platforms API.
--

	cs2005.elements.project = {
		"xmlDeclaration",
		"projectElement",
		"commonProperties",
		"projectProperties",
		"configurations",
		"applicationIcon",
		"references",
	}

	function cs2005.generate(prj)
		p.utf8()

		premake.callarray(cs2005, cs2005.elements.project, prj)

		_p(1,'<ItemGroup>')
		cs2005.files(prj)
		_p(1,'</ItemGroup>')

		cs2005.projectReferences(prj)
		cs2005.targets(prj)
		cs2005.buildEvents(prj)

		p.out('</Project>')
	end


--
-- Write the opening <Project> element.
--

	function cs2005.projectElement(prj)
		local ver = ''
		local action = premake.action.current()
		if action.vstudio.toolsVersion then
			ver = string.format(' ToolsVersion="%s"', action.vstudio.toolsVersion)
		end
		_p('<Project%s DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', ver)
	end


--
-- Write the opening PropertyGroup, which contains the project-level settings.
--

	cs2005.elements.projectProperties = {
		"configurationCondition",
		"platformCondition",
		"productVersion",
		"schemaVersion",
		"projectGuid",
		"outputType",
		"appDesignerFolder",
		"rootNamespace",
		"assemblyName",
		"targetFrameworkVersion",
		"targetFrameworkProfile",
		"fileAlignment",
		"projectTypeGuids",
	}

	function cs2005.projectProperties(prj)
		_p(1,'<PropertyGroup>')
		local cfg = project.getfirstconfig(prj)
		premake.callarray(cs2005, cs2005.elements.projectProperties, cfg)
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the settings for the project configurations.
--

	cs2005.elements.configuration = {
		"propertyGroup",
		"debugProps",
		"outputProps",
		"compilerProps",
	}

	function cs2005.configurations(prj)
		for cfg in project.eachconfig(prj) do
			cs2005.configuration(cfg)
		end
	end

	function cs2005.configuration(cfg)
		premake.callarray(cs2005, cs2005.elements.configuration, cfg)
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the source files item group.
--

	function cs2005.files(prj)
		-- Some settings applied at project level; can't be changed in cfg
		local cfg = project.getfirstconfig(prj)

		-- Try to write file-level elements in the same order as Visual Studio
		local elements = {
			"AutoGen",
			"CopyToOutputDirectory",
			"DesignTime",
			"DependentUpon",
			"DesignTimeSharedInput",
			"Generator",
			"LastGenOutput",
			"SubType",
		}

		local tr = project.getsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node, depth)
				local filecfg = fileconfig.getconfig(node, cfg)
				local fname = path.translate(node.relpath)

				-- Files that live outside of the project tree need to be "linked"
				-- and provided with a project relative pseudo-path. Check for any
				-- leading "../" sequences and, if found, remove them and mark this
				-- path as external.

				local link, count = node.relpath:gsub("%.%.%/", "")
				local external = (count > 0)

				-- Try to provide a little bit of flexibility by allowing virtual
				-- paths for external files. Would be great to support them for all
				-- files but Visual Studio chokes if file is already in project area.

				if external and node.vpath ~= node.relpath then
					link = node.vpath
				end

				-- Deduce what, if any, special attributes are required for this file.
				-- For example, forms may have related source, designer, and resource
				-- files which need to be associated.

				local info = dotnet.fileinfo(filecfg)

				-- Process any sub-elements required by this file; choose the write
				-- element form to use based on the results.

				local contents = premake.capture(function ()
					for _, el in ipairs(elements) do
						local value = info[el]
						if value then
							_p(3,"<%s>%s</%s>", el, value, el)
						end
					end
				end)

				if #contents > 0 or external then
					_p(2,'<%s Include="%s">', info.action, fname)
					if external then
						_p(3,'<Link>%s</Link>', path.translate(link))
					end
					if #contents > 0 then
						_p("%s", contents)
					end
					if info.action == "EmbeddedResource" and cfg.customtoolnamespace then
						_p(3,"<CustomToolNamespace>%s</CustomToolNamespace>", cfg.customtoolnamespace)
					end
					_p(2,'</%s>', info.action)
				else
					_p(2,'<%s Include="%s" />', info.action, fname)
				end

			end
		}, false)
	end


--
-- Write out pre- and post-build events, if provided.
--

	function cs2005.buildEvents(prj)
		local function output(name, steps)
			if #steps > 0 then
				steps = os.translateCommands(steps, p.WINDOWS)
				steps = table.implode(steps, "", "", "\r\n")
				_x(2,'<%sBuildEvent>%s</%sBuildEvent>', name, steps, name)
			end
		end

		local cfg = project.getfirstconfig(prj)
		if #cfg.prebuildcommands > 0 or #cfg.postbuildcommands > 0 then
			_p(1,'<PropertyGroup>')
			output("Pre", cfg.prebuildcommands)
			output("Post", cfg.postbuildcommands)
			_p(1,'</PropertyGroup>')
		end
	end


--
-- Write the compiler flags for a particular configuration.
--

	function cs2005.compilerProps(cfg)
		_x(2,'<DefineConstants>%s</DefineConstants>', table.concat(cfg.defines, ";"))

		_p(2,'<ErrorReport>prompt</ErrorReport>')
		_p(2,'<WarningLevel>4</WarningLevel>')

		if cfg.clr == "Unsafe" then
			_p(2,'<AllowUnsafeBlocks>true</AllowUnsafeBlocks>')
		end

		if cfg.flags.FatalCompileWarnings then
			_p(2,'<TreatWarningsAsErrors>true</TreatWarningsAsErrors>')
		end

		cs2005.debugCommandParameters(cfg)
	end

--
-- Write out the debug start parameters for MonoDevelop/Xamarin Studio.
--

	function cs2005.debugCommandParameters(cfg)
		if #cfg.debugargs > 0 then
			_x(2,'<Commandlineparameters>%s</Commandlineparameters>', table.concat(cfg.debugargs, " "))
		end
	end

--
-- Write out the debugging and optimization flags for a configuration.
--

	function cs2005.debugProps(cfg)
		if cfg.flags.Symbols then
			_p(2,'<DebugSymbols>true</DebugSymbols>')
			_p(2,'<DebugType>full</DebugType>')
		else
			_p(2,'<DebugType>pdbonly</DebugType>')
		end
		_p(2,'<Optimize>%s</Optimize>', iif(config.isOptimizedBuild(cfg), "true", "false"))
	end


--
-- Write out the target and intermediates settings for a configuration.
--

	function cs2005.outputProps(cfg)
		local outdir = vstudio.path(cfg, cfg.buildtarget.directory)
		_x(2,'<OutputPath>%s\\</OutputPath>', outdir)

		-- Want to set BaseIntermediateOutputPath because otherwise VS will create obj/
		-- anyway. But VS2008 throws up ominous warning if present.
		local objdir = vstudio.path(cfg, cfg.objdir)
		if _ACTION > "vs2008" then
			_x(2,'<BaseIntermediateOutputPath>%s\\</BaseIntermediateOutputPath>', objdir)
			_p(2,'<IntermediateOutputPath>$(BaseIntermediateOutputPath)</IntermediateOutputPath>')
		else
			_x(2,'<IntermediateOutputPath>%s\\</IntermediateOutputPath>', objdir)
		end
	end


--
-- Write out the references item group.
--

	cs2005.elements.references = function(prj)
		return {
			cs2005.assemblyReferences,
			cs2005.nuGetReferences,
		}
	end

	function cs2005.references(prj)
		_p(1,'<ItemGroup>')
		p.callArray(cs2005.elements.references, prj)
		_p(1,'</ItemGroup>')
	end


--
-- Write the list of assembly (system, or non-sibling) references.
--

	function cs2005.assemblyReferences(prj)
		-- C# doesn't support per-configuration links (does it?) so just use
		-- the settings from the first available config instead
		local cfg = project.getfirstconfig(prj)

		config.getlinks(cfg, "system", function(original, decorated)
			local name = path.getname(decorated)
			if path.getextension(name) == ".dll" then
				name = name.sub(name, 1, -5)
			end

			if decorated:find("/", nil, true) then
				_x(2,'<Reference Include="%s">', name)
				_x(3,'<HintPath>%s</HintPath>', path.appendextension(path.translate(decorated), ".dll"))

				if not config.isCopyLocal(prj, original, true) then
					_p(3,"<Private>False</Private>")
				end

				_p(2,'</Reference>')
			else
				_x(2,'<Reference Include="%s" />', name)
			end
		end)
	end


--
-- Write the list of NuGet references.
--

	function cs2005.nuGetReferences(prj)
		if _ACTION >= "vs2010" then
			for i = 1, #prj.nuget do
				local package = prj.nuget[i]
				_x(2, '<Reference Include="%s">', vstudio.nuget2010.packageId(package))

				-- We need to write HintPaths for all supported framework
				-- versions. The last HintPath will override any previous
				-- HintPaths (if the condition is met that is).

				for _, frameworkVersion in ipairs(cs2005.identifyFrameworkVersions(prj)) do
					local assembly = vstudio.path(
						prj,
						p.filename(
							prj.solution,
							string.format(
								"packages\\%s\\lib\\%s\\%s.dll",
								vstudio.nuget2010.packageName(package),
								cs2005.formatNuGetFrameworkVersion(frameworkVersion),
								vstudio.nuget2010.packageId(package)
							)
						)
					)

					_x(3, '<HintPath Condition="Exists(\'%s\')">%s</HintPath>', assembly, assembly)
				end

				_p(3, '<Private>True</Private>')
				_p(2, '</Reference>')
			end
		end
	end


--
-- Write the list of project dependencies.
--
	function cs2005.projectReferences(prj)
		_p(1,'<ItemGroup>')

		local deps = project.getdependencies(prj, 'linkOnly')
		if #deps > 0 then
			for _, dep in ipairs(deps) do
				local relpath = vstudio.path(prj, vstudio.projectfile(dep))
				_x(2,'<ProjectReference Include="%s">', relpath)
				_p(3,'<Project>{%s}</Project>', dep.uuid)
				_x(3,'<Name>%s</Name>', dep.name)

				if not config.isCopyLocal(prj, dep.name, true) then
					_p(3,"<Private>False</Private>")
				end

				_p(2,'</ProjectReference>')
			end
		end

		_p(1,'</ItemGroup>')
	end


--
-- Return the Visual Studio architecture identification string. The logic
-- to select this is getting more complicated in VS2010, but I haven't
-- tackled all the permutations yet.
--

	function cs2005.arch(cfg)
		local arch = vstudio.archFromConfig(cfg)
		if arch == "Any CPU" then
			arch = "AnyCPU"
		end
		return arch
	end


--
-- Write the PropertyGroup element for a specific configuration block.
--

	function cs2005.propertyGroup(cfg)
		local platform = vstudio.projectPlatform(cfg)
		local arch = cs2005.arch(cfg)
		p.push('<PropertyGroup Condition=" \'$(Configuration)|$(Platform)\' == \'%s|%s\' ">', platform, arch)
		if arch ~= "AnyCPU" or _ACTION > "vs2008" then
			p.x('<PlatformTarget>%s</PlatformTarget>', arch)
		end
	end


--
-- Generators for individual project elements.
--

	function cs2005.applicationIcon(prj)
		if prj.icon then
			local icon = vstudio.path(prj, prj.icon)
			_p(1,'<PropertyGroup>')
			_x(2,'<ApplicationIcon>%s</ApplicationIcon>', icon)
			_p(1,'</PropertyGroup>')
		end
	end

---------------------------------------------------------------------------
--
-- Support functions
--
---------------------------------------------------------------------------

--
-- Format and return a Visual Studio Condition attribute.
--

	function cs2005.condition(cfg)
		return string.format('Condition="\'$(Configuration)|$(Platform)\'==\'%s\'"', premake.esc(vstudio.projectConfig(cfg)))
	end


--
-- Build and return a list of all .NET Framework versions up to and including
-- the project's framework version.
--

	function cs2005.identifyFrameworkVersions(prj)
		local frameworks = {}

		local cfg = p.project.getfirstconfig(prj)
		local action = premake.action.current()
		local targetFramework = cfg.dotnetframework or action.vstudio.targetFramework

		for _, frameworkVersion in ipairs(vstudio.frameworkVersions) do
			if frameworkVersion == targetFramework then
				break
			end

			table.insert(frameworks, frameworkVersion)
		end

		table.insert(frameworks, targetFramework)

		return frameworks
	end


--
-- When given a .NET Framework version, returns it formatted for NuGet.
--

	function cs2005.formatNuGetFrameworkVersion(framework)
		return "net" .. framework:gsub("%.", "")
	end

---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------

	function cs2005.appDesignerFolder(cfg)
		_p(2,'<AppDesignerFolder>Properties</AppDesignerFolder>')
	end


	function cs2005.assemblyName(cfg)
		_p(2,'<AssemblyName>%s</AssemblyName>', cfg.buildtarget.basename)
	end


	function cs2005.commonProperties(prj)
		if _ACTION > "vs2010" then
			_p(1,'<Import Project="$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props" Condition="Exists(\'$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props\')" />')
		end
	end


	function cs2005.configurationCondition(cfg)
		_x(2,'<Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', cfg.buildcfg)
	end


	function cs2005.fileAlignment(cfg)
		if _ACTION >= "vs2010" then
			_p(2,'<FileAlignment>512</FileAlignment>')
		end
	end


	function cs2005.outputType(cfg)
		_p(2,'<OutputType>%s</OutputType>', dotnet.getkind(cfg))
	end


	function cs2005.platformCondition(cfg)
		_p(2,'<Platform Condition=" \'$(Platform)\' == \'\' ">%s</Platform>', cs2005.arch(cfg.project))
	end


	function cs2005.productVersion(cfg)
		local action = premake.action.current()
		if action.vstudio.productVersion then
			_p(2,'<ProductVersion>%s</ProductVersion>', action.vstudio.productVersion)
		end
	end

	function cs2005.projectGuid(cfg)
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', cfg.uuid)
	end


	function cs2005.projectTypeGuids(cfg)
		if cfg.flags.WPF then
			_p(2,'<ProjectTypeGuids>{60dc8134-eba5-43b8-bcc9-bb4bc16c2548};{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</ProjectTypeGuids>')
		end
	end


	function cs2005.rootNamespace(cfg)
		_p(2,'<RootNamespace>%s</RootNamespace>', cfg.namespace or cfg.buildtarget.basename)
	end


	function cs2005.schemaVersion(cfg)
		local action = premake.action.current()
		if action.vstudio.csprojSchemaVersion then
			_p(2,'<SchemaVersion>%s</SchemaVersion>', action.vstudio.csprojSchemaVersion)
		end
	end


	function cs2005.targetFrameworkVersion(cfg)
		local action = premake.action.current()
		local framework = cfg.dotnetframework or action.vstudio.targetFramework
		if framework then
			_p(2,'<TargetFrameworkVersion>v%s</TargetFrameworkVersion>', framework)
		end
	end


	function cs2005.targetFrameworkProfile(cfg)
		if _ACTION == "vs2010" then
			_p(2,'<TargetFrameworkProfile>')
			_p(2,'</TargetFrameworkProfile>')
		end
	end


	function cs2005.targets(prj)
		local bin = iif(_ACTION <= "vs2010", "MSBuildBinPath", "MSBuildToolsPath")
		_p(1,'<Import Project="$(%s)\\Microsoft.CSharp.targets" />', bin)
		_p(1,'<!-- To modify your build process, add your task inside one of the targets below and uncomment it.')
		_p(1,'     Other similar extension points exist, see Microsoft.Common.targets.')
		_p(1,'<Target Name="BeforeBuild">')
		_p(1,'</Target>')
		_p(1,'<Target Name="AfterBuild">')
		_p(1,'</Target>')
		_p(1,'-->')
	end


	function cs2005.xmlDeclaration()
		if _ACTION > "vs2008" then
			p.xmlUtf8()
		end
	end

