--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005+ C# project.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	p.vstudio.cs2005 = {}

	local vstudio = p.vstudio
	local cs2005 = p.vstudio.cs2005
	local dotnetbase = p.vstudio.dotnetbase
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local dotnet = p.tools.dotnet

	cs2005.elements = {}

	cs2005.elements.project = function (prj)
		if dotnetbase.isNewFormatProject(prj) then
			return {
				dotnetbase.projectElement,
				dotnetbase.projectProperties,
				dotnetbase.configurations,
				dotnetbase.applicationIcon,
				dotnetbase.references
			}
		else
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
	end

	cs2005.elements.projectProperties = function (cfg)
		if dotnetbase.isNewFormatProject(cfg) then
			return {
				dotnetbase.outputType,
				dotnetbase.appDesignerFolder,
				dotnetbase.rootNamespace,
				dotnetbase.assemblyName,
				dotnetbase.netcore.targetFramework,
				dotnetbase.allowUnsafeBlocks,
				dotnetbase.fileAlignment,
				dotnetbase.bindingRedirects,
				dotnetbase.netcore.useWpf,
				dotnetbase.csversion,
				dotnetbase.netcore.enableDefaultCompileItems,
			}
		else
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
				dotnetbase.csversion,
			}
		end
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
		dotnetbase.prepare(cs2005)
		dotnetbase.generate(prj)
	end

	function cs2005.targets(prj)
		if not dotnetbase.isNewFormatProject(prj) then
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
	end
