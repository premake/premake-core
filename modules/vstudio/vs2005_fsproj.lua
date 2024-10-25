--
-- vs2005_fsproj.lua
-- Generate a Visual Studio 2005+ F# project.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.fs2005 = {}

	local vstudio = p.vstudio
	local fs2005 = p.vstudio.fs2005
	local dotnetbase = p.vstudio.dotnetbase
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local dotnet = p.tools.dotnet

	fs2005.elements = {}

	fs2005.elements.project = function ()
		return {
			dotnetbase.xmlDeclaration,
			dotnetbase.projectElement,
			dotnetbase.commonProperties,
			dotnetbase.projectProperties,
			dotnetbase.configurations,
			dotnetbase.applicationIcon,
			dotnetbase.references
		}
	end

	fs2005.elements.projectProperties = function ()
		return {
			dotnetbase.configurationCondition,
			dotnetbase.platformCondition,
			dotnetbase.schemaVersion,
			dotnetbase.productVersion,
			dotnetbase.projectGuid,
			dotnetbase.outputType,
			dotnetbase.appDesignerFolder,
			dotnetbase.rootNamespace,
			dotnetbase.assemblyName,
			dotnetbase.targetFrameworkVersion,
			dotnetbase.targetFrameworkProfile,
			dotnetbase.projectTypeGuids
		}
	end

	fs2005.elements.configuration = function ()
		return {
			dotnetbase.propertyGroup,
			dotnetbase.debugProps,
			dotnetbase.outputProps,
			dotnetbase.compilerProps,
			dotnetbase.additionalProps,
			dotnetbase.NoWarn,
			fs2005.tailCalls
		}
	end

	function fs2005.generate(prj)
		dotnetbase.prepare(fs2005)
		dotnetbase.generate(prj)
	end

	function fs2005.tailCalls(cfg)
		local tc
		if cfg.tailcalls == nil then
			tc = config.isDebugBuild(cfg)
		else
			tc = cfg.tailcalls
		end
		_p(2, '<Tailcalls>%s</Tailcalls>', iif(tc, "true", "false"))
	end

	function fs2005.targets(prj)
		_p(1, '<Choose>')
		_p(2, '<When Condition="\'$(VisualStudioVersion)\' == \'11.0\'">')
		_p(3, '<PropertyGroup Condition="Exists(\'$(MSBuildExtensionsPath32)\\..\\Microsoft SDKs\\F#\\3.0\\Framework\\v4.0\\Microsoft.FSharp.Targets\')">')
		_p(4, '<FSharpTargetsPath>$(MSBuildExtensionsPath32)\\Microsoft\\VisualStudio\\v$(VisualStudioVersion)\\FSharp\\Microsoft.FSharp.Targets</FSharpTargetsPath>')
		_p(3, '</PropertyGroup>')
		_p(2, '</When>')
		_p(2, '<Otherwise>')
		_p(2, '<PropertyGroup Condition="Exists(\'$(MSBuildExtensionsPath32)\\Microsoft\\VisualStudio\\v$(VisualStudioVersion)\\FSharp\\Microsoft.FSharp.Targets\')">')
		_p(3, '<FSharpTargetsPath>$(MSBuildExtensionsPath32)\\Microsoft\\VisualStudio\\v$(VisualStudioVersion)\\FSharp\\Microsoft.FSharp.Targets</FSharpTargetsPath>')
		_p(2, '</PropertyGroup>')
		_p(2, '</Otherwise>')
		_p(1, '</Choose>')
		_p(1, '<Import Project="$(FSharpTargetsPath)" />')
	end
