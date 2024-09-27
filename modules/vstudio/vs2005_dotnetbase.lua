--
-- vs2005_dotnetbase.lua
-- Generate a Visual Studio 2005+ .NET project.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	p.vstudio.dotnetbase = {}

	local vstudio = p.vstudio
	local vs2005 = p.vstudio.vs2005
	local dotnetbase  = p.vstudio.dotnetbase
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local dotnet = p.tools.dotnet


	dotnetbase.elements = {}
	dotnetbase.langObj = {}
	dotnetbase.netcore = {}

--
-- Generate a Visual Studio 200x dotnet project, with support for the new platforms API.
--

	function dotnetbase.prepare(langObj)
		dotnetbase.elements.project = langObj.elements.project
		dotnetbase.elements.projectProperties = langObj.elements.projectProperties
		dotnetbase.elements.configuration = langObj.elements.configuration

		dotnetbase.langObj = langObj
	end


	function dotnetbase.generate(prj)
		p.utf8()

		p.callArray(dotnetbase.elements.project, prj)

		_p(1,'<ItemGroup>')
		dotnetbase.files(prj)
		_p(1,'</ItemGroup>')

		dotnetbase.projectReferences(prj)
		dotnetbase.packageReferences(prj)
		dotnetbase.langObj.targets(prj)
		dotnetbase.buildEvents(prj)

		p.out('</Project>')
	end


--
-- Write the opening <Project> element.
--

	function dotnetbase.projectElement(prj)
		if dotnetbase.isNewFormatProject(prj) then
			if prj.flags.WPF then
				_p('<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">')
			else
				_p('<Project Sdk="Microsoft.NET.Sdk">')
			end
		else
			local ver = ''
			local action = p.action.current()
			if action.vstudio.toolsVersion then
				ver = string.format(' ToolsVersion="%s"', action.vstudio.toolsVersion)
			end
			_p('<Project%s DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', ver)
		end
	end


--
-- Write the opening PropertyGroup, which contains the project-level settings.
--


	function dotnetbase.projectProperties(prj)
		_p(1,'<PropertyGroup>')
		local cfg = project.getfirstconfig(prj)
		p.callArray(dotnetbase.elements.projectProperties, cfg)
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the settings for the project configurations.
--


	function dotnetbase.configurations(prj)
		for cfg in project.eachconfig(prj) do
			dotnetbase.configuration(cfg)
		end
	end

	function dotnetbase.configuration(cfg)
		p.callArray(dotnetbase.elements.configuration, cfg)
		_p(1,'</PropertyGroup>')
	end


	function dotnetbase.dofile(node, cfg, condition)
		local filecfg = fileconfig.getconfig(node, cfg)
		if filecfg then
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

			local contents = p.capture(function ()
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

				for _, el in ipairs(elements) do
					local value = info[el]
					if value then
						_p(3,"<%s>%s</%s>", el, value, el)
					end
				end
				if info.action == "EmbeddedResource" and cfg.customtoolnamespace then
					_p(3,"<CustomToolNamespace>%s</CustomToolNamespace>", cfg.customtoolnamespace)
				end
			end)

			if #contents > 0 or external then
				_p(2,'<%s%s Include="%s">', info.action, condition, fname)
				if external and info.action ~= "EmbeddedResource" then
					_p(3,'<Link>%s</Link>', path.translate(link))
				end
				if #contents > 0 then
					_p("%s", contents)
				end
				_p(2,'</%s>', info.action)
			else
				_p(2,'<%s%s Include="%s" />', info.action, condition, fname)
			end
		end
	end


--
-- Write out the source files item group.
--

	function dotnetbase.files(prj)
		local firstcfg = project.getfirstconfig(prj)

		local processfcfg = function(node)
			-- test if all fileinfo's are going to be the same for each config.
			local allsame = true
			local first = nil
			for cfg in project.eachconfig(prj) do
				local filecfg = fileconfig.getconfig(node, cfg)
				local info = dotnet.fileinfo(filecfg)

				if first == nil then
					first = info
				elseif not table.equals(first, info) then
					allsame = false
				end
			end

			-- output to proj file.
			if allsame then
				dotnetbase.dofile(node, firstcfg, '')
			else
				for cfg in project.eachconfig(prj) do
					dotnetbase.dofile(node, cfg, ' ' .. dotnetbase.condition(cfg))
				end
			end
		end

		if project.isfsharp(prj) then
			sorter = function(a,b)
				verbosef('Sorting F# proj file (%s, %s), index %s < %s', a.name, b.name, a.order, b.order)
				return a.order < b.order
			end

			table.sort(prj._.files, sorter)
			table.foreachi(prj._.files, processfcfg)
		else
			local tr = project.getsourcetree(prj)
			p.tree.traverse(tr, {
				onleaf = processfcfg
			}, false)
		end
	end


--
-- Write out pre- and post-build events, if provided.
--

	function dotnetbase.buildEvents(prj)
		local function output(name, steps)
			if #steps > 0 then
				steps = os.translateCommandsAndPaths(steps, prj.basedir, prj.location)
				steps = table.implode(steps, "", "", "\r\n")
				_x(2,'<%sBuildEvent>%s</%sBuildEvent>', name, steps, name)
			end
		end

		for cfg in project.eachconfig(prj) do
			if #cfg.prebuildcommands > 0 or #cfg.postbuildcommands > 0 then
				_p(1,'<PropertyGroup %s>', dotnetbase.condition(cfg))
				output("Pre", cfg.prebuildcommands)
				output("Post", cfg.postbuildcommands)
				_p(1,'</PropertyGroup>')
			end
		end
	end

--
-- Write out the additional props.
--

	function dotnetbase.additionalProps(cfg)
		local function recurseTableIfNeeded(tbl, tab_level)
			for key, value in spairs(tbl) do
				if (type(value) == "table") then
					_p(tab_level, '<%s>', key)
					recurseTableIfNeeded(value, tab_level + 1)
					_p(tab_level, '</%s>', key)
				else
					_p(tab_level, '<%s>%s</%s>', key, vs2005.esc(value), key)
				end
			end
		end
		for i = 1, #cfg.vsprops do
			recurseTableIfNeeded(cfg.vsprops[i], 2)
		end
	end


--
-- Write the compiler flags for a particular configuration.
--

	function dotnetbase.compilerProps(cfg)
		_x(2,'<DefineConstants>%s</DefineConstants>', table.concat(cfg.defines, ";"))

		_p(2,'<ErrorReport>prompt</ErrorReport>')
		_p(2,'<WarningLevel>4</WarningLevel>')

		if not dotnetbase.isNewFormatProject(cfg) then
			dotnetbase.allowUnsafeBlocks(cfg)
		end

		if cfg.flags.FatalCompileWarnings then
			_p(2,'<TreatWarningsAsErrors>true</TreatWarningsAsErrors>')
		end

		dotnetbase.debugCommandParameters(cfg)
	end

--
-- Write out the debug start parameters for MonoDevelop/Xamarin Studio.
--

	function dotnetbase.debugCommandParameters(cfg)
		if #cfg.debugargs > 0 then
			_x(2,'<Commandlineparameters>%s</Commandlineparameters>', table.concat(cfg.debugargs, " "))
		end
	end

--
-- Write out the debugging and optimization flags for a configuration.
--

	function dotnetbase.debugProps(cfg)
		if _ACTION >= "vs2019" then
			if cfg.symbols == "Full" then
				_p(2,'<DebugType>full</DebugType>')
				_p(2,'<DebugSymbols>true</DebugSymbols>')
			elseif cfg.symbols == p.OFF then
				_p(2,'<DebugType>none</DebugType>')
				_p(2,'<DebugSymbols>false</DebugSymbols>')
			elseif cfg.symbols == p.ON or cfg.symbols == "FastLink" then
				_p(2,'<DebugType>pdbonly</DebugType>')
				_p(2,'<DebugSymbols>true</DebugSymbols>')
			else
				_p(2,'<DebugType>portable</DebugType>')
				_p(2,'<DebugSymbols>true</DebugSymbols>')
			end
		else
			if cfg.symbols == p.ON then
				_p(2,'<DebugSymbols>true</DebugSymbols>')
				_p(2,'<DebugType>full</DebugType>')
			else
				_p(2,'<DebugType>pdbonly</DebugType>')
			end
		end
		_p(2,'<Optimize>%s</Optimize>', iif(config.isOptimizedBuild(cfg), "true", "false"))
	end


--
-- Write out the target and intermediates settings for a configuration.
--

	function dotnetbase.outputProps(cfg)
		local outdir = vstudio.path(cfg, cfg.buildtarget.directory)
		_x(2,'<OutputPath>%s\\</OutputPath>', outdir)

		-- Want to set BaseIntermediateOutputPath because otherwise VS will create obj/
		-- anyway. But VS2008 throws up ominous warning if present.
		local objdir = vstudio.path(cfg, cfg.objdir)
		if _ACTION > "vs2008" and not dotnetbase.isNewFormatProject(cfg) then
			_x(2,'<BaseIntermediateOutputPath>%s\\</BaseIntermediateOutputPath>', objdir)
			_p(2,'<IntermediateOutputPath>$(BaseIntermediateOutputPath)</IntermediateOutputPath>')
		else
			_x(2,'<IntermediateOutputPath>%s\\</IntermediateOutputPath>', objdir)
		end
	end


--
-- Write out the references item group.
--

	dotnetbase.elements.references = function(cfg)
		return {
			dotnetbase.assemblyReferences,
			dotnetbase.nuGetReferences,
		}
	end

	function dotnetbase.references(prj)
		for cfg in project.eachconfig(prj) do
			_p(1,'<ItemGroup %s>', dotnetbase.condition(cfg))
			p.callArray(dotnetbase.elements.references, cfg)
			_p(1,'</ItemGroup>')
		end
	end


--
-- Write the list of assembly (system, or non-sibling) references.
--

	function dotnetbase.assemblyReferences(cfg)
		local prj = cfg.project
		config.getlinks(cfg, "system", function(original, decorated)
			local name = path.getname(decorated)
			if path.getextension(name) == ".dll" then
				name = name.sub(name, 1, -5)
			end

			if decorated:find("/", nil, true) then
				_x(2,'<Reference Include="%s">', name)
				local decPath, decVars = decorated:match("(.-),")
				if not decPath then
					decPath = decorated
				end

				_x(3,'<HintPath>%s</HintPath>', path.appendextension(path.translate(decPath), ".dll"))

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
-- This is a bit janky. To compare versions, we extract all numbers from the
-- given string and right-pad the result with zeros. Then we can just do a
-- lexicographical compare on the resulting strings.
--
-- This is so that we can compare version strings such as "4.6" and "net451"
-- with each other.
--

	function dotnetbase.makeVersionComparable(version)
		local numbers = ""

		for number in version:gmatch("%d") do
			numbers = numbers .. number
		end

		return string.format("%-10d", numbers):gsub(" ", "0")
	end


--
-- https://github.com/NuGet/NuGet.Client/blob/dev/test/NuGet.Core.Tests/NuGet.Frameworks.Test/NuGetFrameworkParseTests.cs
--

	function dotnetbase.frameworkVersionForFolder(folder)
		-- If this exporter ever supports frameworks such as "netstandard1.3",
		-- "sl4", "sl5", "uap10", "wp8" or "wp71", this code will need changing
		-- to match the right folders, depending on the current framework.

		-- Right now this only matches folders for the .NET Framework.

		if folder:match("^net%d+$") or folder:match("^[0-9%.]+$") then
			return dotnetbase.makeVersionComparable(folder)
		elseif folder == "net" then
			return dotnetbase.makeVersionComparable("0")
		end
	end


--
-- Write the list of NuGet references.
--

	function dotnetbase.nuGetReferences(cfg)
		local prj = cfg.project
		if _ACTION >= "vs2010" and not vstudio.nuget2010.supportsPackageReferences(prj) then
			for _, package in ipairs(prj.nuget) do
				local id = vstudio.nuget2010.packageId(package)
				local packageAPIInfo = vstudio.nuget2010.packageAPIInfo(prj, package)

				local action = p.action.current()
				local targetFramework = cfg.dotnetframework or action.vstudio.targetFramework

				local targetVersion = dotnetbase.makeVersionComparable(targetFramework)

				-- Figure out what folder contains the files for the nearest
				-- supported .NET Framework version.

				local files = {}

				local bestVersion, bestFolder

				for _, file in ipairs(packageAPIInfo.packageEntries) do
					local folder = file:match("^lib[\\/](.+)[\\/]")

					if folder and path.hasextension(file, ".dll") then
						local version = dotnetbase.frameworkVersionForFolder(folder)

						if version then
							files[folder] = files[folder] or {}
							table.insert(files[folder], file)

							if version <= targetVersion and (not bestVersion or version > bestVersion) then
								bestVersion = version
								bestFolder = folder
							end
						end
					end
				end

				if not bestVersion then
					p.error("NuGet package '%s' is not compatible with project '%s' .NET Framework version '%s'", id, prj.name, targetFramework)
				end

				-- Now, add references for all DLLs in that folder.

				for _, file in ipairs(files[bestFolder]) do
					-- There's some stuff missing from this include that we
					-- can't get from the API and would need to download and
					-- extract the package to figure out. It looks like we can
					-- just omit it though.
					--
					-- So, for example, instead of:
					--
					-- <Reference Include="nunit.framework, Version=3.6.1.0,
					-- <Culture=neutral, PublicKeyToken=2638cd05610744eb,
					-- <processorArchitecture=MSIL">
					--
					-- We're just outputting:
					--
					-- <Reference Include="nunit.framework">

					_x(2, '<Reference Include="%s">', path.getbasename(file))
					_x(3, '<HintPath>%s</HintPath>', vstudio.path(prj, p.filename(prj.workspace, string.format("packages\\%s.%s\\%s", id, packageAPIInfo.verbatimVersion or packageAPIInfo.version, file))))

					if config.isCopyLocal(prj, package, true) then
						_p(3, '<Private>True</Private>')
					else
						_p(3, '<Private>False</Private>')
					end

					_p(2, '</Reference>')
				end
			end
		end
	end


--
-- Write the list of project dependencies.
--
	function dotnetbase.projectReferences(prj)
		if not dotnetbase.isNewFormatProject(prj) then
			_p(1,'<ItemGroup>')
		end

		local deps = project.getdependencies(prj, 'linkOnly')
		if #deps > 0 then
			if dotnetbase.isNewFormatProject(prj) then
				_p(1,'<ItemGroup>')
			end

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

			if dotnetbase.isNewFormatProject(prj) then
				_p(1,'</ItemGroup>')
			end
		end

		if not dotnetbase.isNewFormatProject(prj) then
			_p(1,'</ItemGroup>')
		end
	end

--
-- Write the list of package dependencies.
--
	function dotnetbase.packageReferences(prj)
		if vstudio.nuget2010.supportsPackageReferences(prj) then
			local hasNuget = prj.nuget and #prj.nuget>0
			for cfg in project.eachconfig(prj) do
				if cfg.nuget and #cfg.nuget>0 then
					hasNuget = true
				end
			end
			if hasNuget then
				_p(1,'<ItemGroup>')
				if prj.nuget and #prj.nuget>0 then
					for _, package in ipairs(prj.nuget) do
						_p(2,'<PackageReference Include="%s" Version="%s"/>', vstudio.nuget2010.packageId(package), vstudio.nuget2010.packageVersion(package))
					end
				end
				for cfg in project.eachconfig(prj) do
					if cfg.nuget and #cfg.nuget>0 then
						for _, package in ipairs(cfg.nuget) do
							if prj.nuget[package]==nil then
								_p(2,'<PackageReference Include="%s" Version="%s" %s/>', vstudio.nuget2010.packageId(package), vstudio.nuget2010.packageVersion(package), dotnetbase.condition(cfg))
							end
						end
					end
				end
				_p(1,'</ItemGroup>')
			end
		end
	end

--
-- Return the Visual Studio architecture identification string. The logic
-- to select this is getting more complicated in VS2010, but I haven't
-- tackled all the permutations yet.
--

	function dotnetbase.arch(cfg)
		local arch = vstudio.archFromConfig(cfg)
		if arch == "Any CPU" then
			arch = "AnyCPU"
		end
		return arch
	end


--
-- Write the PropertyGroup element for a specific configuration block.
--

	function dotnetbase.propertyGroup(cfg)
		p.push('<PropertyGroup %s>', dotnetbase.condition(cfg))

		local arch = dotnetbase.arch(cfg)
		if arch ~= "AnyCPU" or _ACTION > "vs2008" then
			p.x('<PlatformTarget>%s</PlatformTarget>', arch)
		end
	end


--
-- Generators for individual project elements.
--

	function dotnetbase.applicationIcon(prj)
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

	function dotnetbase.condition(cfg)
		local platform = vstudio.projectPlatform(cfg)
		local arch = dotnetbase.arch(cfg)
		return string.format('Condition=" \'$(Configuration)|$(Platform)\' == \'%s|%s\' "', platform, arch)
	end


--
-- When given a .NET Framework version, returns it formatted for NuGet.
--

	function dotnetbase.formatNuGetFrameworkVersion(framework)
		return "net" .. framework:gsub("%.", "")
	end

---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------

	function dotnetbase.appDesignerFolder(cfg)
		_p(2,'<AppDesignerFolder>Properties</AppDesignerFolder>')
	end


	function dotnetbase.assemblyName(cfg)
		if not dotnetbase.isNewFormatProject(cfg) --[[or cfg.assemblyname]] then
			_p(2,'<AssemblyName>%s</AssemblyName>', cfg.buildtarget.basename)
		end
	end


	function dotnetbase.commonProperties(prj)
		if _ACTION > "vs2010" then
			_p(1,'<Import Project="$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props" Condition="Exists(\'$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props\')" />')
		end
	end


	function dotnetbase.configurationCondition(cfg)
		_x(2,'<Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', cfg.buildcfg)
	end


	function dotnetbase.fileAlignment(cfg)
		if _ACTION >= "vs2010" and not dotnetbase.isNewFormatProject(cfg) then
			_p(2,'<FileAlignment>512</FileAlignment>')
		end
	end


	function dotnetbase.bindingRedirects(cfg)
		if _ACTION >= "vs2015" and not dotnetbase.isNewFormatProject(cfg) then
			_p(2, '<AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>')
		end
	end


	function dotnetbase.outputType(cfg)
		_p(2,'<OutputType>%s</OutputType>', dotnet.getkind(cfg))
	end


	function dotnetbase.platformCondition(cfg)
		_p(2,'<Platform Condition=" \'$(Platform)\' == \'\' ">%s</Platform>', dotnetbase.arch(cfg.project))
	end


	function dotnetbase.productVersion(cfg)
		local action = p.action.current()
		if action.vstudio.productVersion then
			_p(2,'<ProductVersion>%s</ProductVersion>', action.vstudio.productVersion)
		end
	end

	function dotnetbase.projectGuid(cfg)
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', cfg.uuid)
	end


	function dotnetbase.projectTypeGuids(cfg)
		if cfg.flags.WPF then
			_p(2,'<ProjectTypeGuids>{60dc8134-eba5-43b8-bcc9-bb4bc16c2548};{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</ProjectTypeGuids>')
		end
	end


	function dotnetbase.rootNamespace(cfg)
		if not dotnetbase.isNewFormatProject(cfg) or cfg.namespace then
			_p(2,'<RootNamespace>%s</RootNamespace>', cfg.namespace or cfg.buildtarget.basename)
		end
	end


	function dotnetbase.schemaVersion(cfg)
		local action = p.action.current()
		if action.vstudio.csprojSchemaVersion then
			_p(2,'<SchemaVersion>%s</SchemaVersion>', action.vstudio.csprojSchemaVersion)
		end
	end


	function dotnetbase.NoWarn(cfg)
		if #cfg.disablewarnings > 0 then
			local warnings = table.concat(cfg.disablewarnings, ";")
			_p(2,'<NoWarn>%s</NoWarn>', warnings)
		end
	end

	function dotnetbase.targetFrameworkVersion(cfg)
		local action = p.action.current()
		local framework = cfg.dotnetframework or action.vstudio.targetFramework
		if framework and not dotnetbase.isNewFormatProject(cfg) then
			_p(2,'<TargetFrameworkVersion>v%s</TargetFrameworkVersion>', framework)
		end
	end

	function dotnetbase.csversion(cfg)
		if cfg.csversion then
			_p(2,'<LangVersion>%s</LangVersion>', cfg.csversion)
		end
	end


	function dotnetbase.targetFrameworkProfile(cfg)
		if _ACTION == "vs2010" then
			_p(2,'<TargetFrameworkProfile>')
			_p(2,'</TargetFrameworkProfile>')
		end
	end


	function dotnetbase.xmlDeclaration()
		if _ACTION > "vs2008" then
			p.xmlUtf8()
		end
	end

	function dotnetbase.documentationfile(cfg)
		if cfg.documentationFile then
			if _ACTION > "vs2015" and cfg.documentationFile == "" then
				_p(2,'<GenerateDocumentationFile>true</GenerateDocumentationFile>')
			else
				local documentationFile = iif(cfg.documentationFile ~= "", cfg.documentationFile, cfg.targetdir)
				_p(2, string.format('<DocumentationFile>%s\\%s.xml</DocumentationFile>', vstudio.path(cfg, documentationFile),cfg.project.name))
			end
		end
	end

	function dotnetbase.isNewFormatProject(cfg)
		local framework = cfg.dotnetframework
		if not framework then
			return false
		end

		if framework:find('^net') ~= nil then
			return true
		end

		return false
	end

	function dotnetbase.netcore.targetFramework(cfg)
		local action = p.action.current()
		local framework = cfg.dotnetframework or action.vstudio.targetFramework
		if framework and dotnetbase.isNewFormatProject(cfg) then
			_p(2,'<TargetFramework>%s</TargetFramework>', framework)
		end
	end

	function dotnetbase.netcore.enableDefaultCompileItems(cfg)
		_p(2,'<EnableDefaultCompileItems>%s</EnableDefaultCompileItems>', iif(cfg.enableDefaultCompileItems, "true", "false"))
	end

	function dotnetbase.netcore.useWpf(cfg)
		if cfg.flags.WPF then
			_p(2,'<UseWpf>true</UseWpf>')
		end
	end

	function dotnetbase.allowUnsafeBlocks(cfg)
		if cfg.clr == "Unsafe" then
			_p(2,'<AllowUnsafeBlocks>true</AllowUnsafeBlocks>')
		end
	end
