--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005+ C# project.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	p.vstudio.cs2005 = {}
	p.vstudio.netcore = {}
	
	local vstudio = p.vstudio
	local cs2005 = p.vstudio.cs2005
	local netcore = p.vstudio.netcore
	local dotnetbase = p.vstudio.dotnetbase
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local dotnet = p.tools.dotnet

	cs2005.elements = {}

	cs2005.elements.project = function ()
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

	cs2005.elements.projectProperties = function ()
		return {
			dotnetbase.configurationCondition,
			dotnetbase.platformCondition,
			dotnetbase.productVersion,
			dotnetbase.schemaVersion,
			dotnetbase.projectGuid,
			dotnetbase.outputType,
			dotnetbase.appDesignerFolder,
			dotnetbase.rootNamespace,
			dotnetbase.assemblyName,
			dotnetbase.targetFrameworkVersion,
			dotnetbase.targetFrameworkProfile,
			dotnetbase.fileAlignment,
			dotnetbase.bindingRedirects,
			dotnetbase.projectTypeGuids,
			dotnetbase.csversion
		}
	end

	cs2005.elements.configuration = function ()
		return {
			dotnetbase.propertyGroup,
			dotnetbase.debugProps,
			dotnetbase.outputProps,
			dotnetbase.compilerProps,
			dotnetbase.NoWarn
		}
	end

	function cs2005.generate(prj)
		if _ACTION == "netcore" then
			dotnetbase.prepare(netcore)
		else
			dotnetbase.prepare(cs2005)
		end
		dotnetbase.generate(prj)
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

	---
	--- .NET Core elements
	---

	netcore.elements = {}

	netcore.elements.project = function ()
		return {
			dotnetbase.netcore.projectElement,
			dotnetbase.projectProperties,
			dotnetbase.configurations,
			dotnetbase.applicationIcon,
			dotnetbase.references
		}
	end

	netcore.elements.projectProperties = function ()
		return {
			dotnetbase.outputType,
			dotnetbase.assemblyName,
			dotnetbase.netcore.targetFramework,
			dotnetbase.targetFrameworkProfile,
			dotnetbase.csversion,
			dotnetbase.netcore.enableDefaultCompileItems
		}
	end

	netcore.elements.configuration = function ()
		return {
			dotnetbase.propertyGroup,
			dotnetbase.debugProps,
			dotnetbase.outputProps,
			dotnetbase.compilerProps,
			dotnetbase.NoWarn
		}
	end