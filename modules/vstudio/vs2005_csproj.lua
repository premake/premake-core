--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005-2010 C# project.
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	local p = premake
	p.vstudio.cs2005 = {}

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

		p.callarray(cs2005, cs2005.elements.project, prj)

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
		local action = p.action.current()
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
		p.callarray(cs2005, cs2005.elements.projectProperties, cfg)
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
		p.callarray(cs2005, cs2005.elements.configuration, cfg)
		_p(1,'</PropertyGroup>')
	end


	function cs2005.dofile(node, cfg, condition)
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
				if external then
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

	function cs2005.files(prj)
		local firstcfg = project.getfirstconfig(prj)

		local tr = project.getsourcetree(prj)
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
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

				-- output to csproj.
				if allsame then
					cs2005.dofile(node, firstcfg, '')
				else
					for cfg in project.eachconfig(prj) do
						cs2005.dofile(node, cfg, ' ' .. cs2005.condition(cfg))
					end
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
				steps = os.translateCommandsAndPaths(steps, prj.basedir, prj.location)
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
		if cfg.symbols == p.ON then
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
-- Write the list of NuGet references.
--

	function cs2005.nuGetReferences(prj)
		if _ACTION >= "vs2010" then
			for _, package in ipairs(prj.nuget) do
				local id = vstudio.nuget2010.packageId(package)
				local packageAPIInfo = vstudio.nuget2010.packageAPIInfo(prj, package)

				local cfg = p.project.getfirstconfig(prj)
				local action = p.action.current()
				local targetFramework = cfg.dotnetframework or action.vstudio.targetFramework

				-- This is a bit janky. To compare versions, we extract all
				-- numbers from the given string and right-pad the result with
				-- zeros. Then we can just do a lexicographical compare on the
				-- resulting strings.
				--
				-- This is so that we can compare version strings such as
				-- "4.6" and "net451" with each other.

				local function makeVersionComparable(a)
					local numbers = ""

					for number in a:gmatch("%d") do
						numbers = numbers .. number
					end

					return string.format("%-10d", numbers):gsub(" ", "0")
				end

				local targetVersion = makeVersionComparable(targetFramework)

				-- Figure out what folder contains the files for the nearest
				-- supported .NET Framework version.

				local files = {}

				local bestVersion, bestFolder

				for _, file in ipairs(packageAPIInfo.packageEntries) do
					-- If this exporter ever supports frameworks such as
					-- "netstandard1.3", "sl4", "sl5", "uap10", "wp8" or
					-- "wp71", this code will need changing to match the right
					-- folders.

					local folder = file:match("^lib\\net(%d+)\\")

					if folder and path.hasextension(file, ".dll") then
						files[folder] = files[folder] or {}
						table.insert(files[folder], file)

						local version = makeVersionComparable(file:match("lib\\net(%d+)\\"))

						if version <= targetVersion and (not bestVersion or version > bestVersion) then
							bestVersion = version
							bestFolder = folder
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
					_x(3, '<HintPath>%s</HintPath>', vstudio.path(prj, p.filename(prj.solution, string.format("packages\\%s.%s\\%s", id, packageAPIInfo.verbatimVersion or packageAPIInfo.version, file))))

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
		p.push('<PropertyGroup %s>', cs2005.condition(cfg))

		local arch = cs2005.arch(cfg)
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
		local platform = vstudio.projectPlatform(cfg)
		local arch = cs2005.arch(cfg)
		return string.format('Condition=" \'$(Configuration)|$(Platform)\' == \'%s|%s\' "', platform, arch)
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
		local action = p.action.current()
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
		local action = p.action.current()
		if action.vstudio.csprojSchemaVersion then
			_p(2,'<SchemaVersion>%s</SchemaVersion>', action.vstudio.csprojSchemaVersion)
		end
	end


	function cs2005.targetFrameworkVersion(cfg)
		local action = p.action.current()
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

