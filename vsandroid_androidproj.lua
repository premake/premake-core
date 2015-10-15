--
-- android/vsandroid_androidproj.lua
-- vs-android integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	local android = p.modules.android
	local vsandroid = p.modules.vsandroid
	local vc2010 = p.vstudio.vc2010
	local vstudio = p.vstudio
	local project = p.project


--
-- Add android tools to vstudio actions.
--


	premake.override(vstudio.vs2010, "generateProject", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			p.eol("\r\n")
			p.indent("  ")
			p.escaper(vstudio.vs2010.esc)

			if project.iscpp(prj) then
				p.generate(prj, ".androidproj", vc2010.generate)

				-- Skip generation of empty user files
				local user = p.capture(function() vc2010.generateUser(prj) end)
				if #user > 0 then
					p.generate(prj, ".androidproj.user", function() p.outln(user) end)
				end
			end
		else
			oldfn(prj)
		end
	end)


	premake.override(vstudio, "projectfile", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			return premake.filename(prj, ".androidproj")
		else
			return oldfn(prj)
		end
	end)


	premake.override(vstudio, "tool", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			return "39E2626F-3545-4960-A6E8-258AD8476CE5"
		else
			return oldfn(prj)
		end
	end)


	premake.override(vc2010.elements, "globals", function (oldfn, cfg)
		local elements = oldfn(cfg)

		if cfg.kind == premake.ANDROIDPROJ then
			-- Remove "IgnoreWarnCompileDuplicatedFilename".
			local pos = table.indexof(elements, vc2010.ignoreWarnDuplicateFilename)
			table.remove(elements, pos)
			elements = table.join(elements, {
				android.projectVersion
			})
		end

		return elements
	end)


	function android.projectVersion(cfg)
		_p(2, "<RootNamespace>%s</RootNamespace>", cfg.project.name)
	   	_p(2, "<MinimumVisualStudioVersion>14.0</MinimumVisualStudioVersion>")
		_p(2, "<ProjectVersion>1.0</ProjectVersion>")
	end


	premake.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind == p.ANDROIDPROJ then
			elements = {
				vc2010.useDebugLibraries,
			}
		end
		return elements
	end)


	premake.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind == p.ANDROIDPROJ then
			elements = {
				android.antPackage,
			}
		end
		return elements
	end)


	premake.override(vc2010, "importDefaultProps", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.Default.props" />')
		else
			oldfn(prj)
		end
	end)


	premake.override(vc2010, "importLanguageSettings", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.props" />')
		else
			oldfn(prj)
		end
	end)


	premake.override(vc2010, "propertySheets", function(oldfn, cfg)
		if cfg.kind ~= p.ANDROIDPROJ then
			oldfn(cfg)
		end
	end)


	premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
		if cfg.kind == p.ANDROIDPROJ then
			return {
				vc2010.outDir,
			}
		else
			return oldfn(cfg)
		end
	end)


	premake.override(vc2010, "importLanguageTargets", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.targets" />')
		else
			oldfn(prj)
		end
	end)


	premake.override(vc2010, "categorizeFile", function(base, prj, file)
		if prj.kind ~= p.ANDROIDPROJ then
			return base(prj, file)
		end

		local filename = path.getname(file.name):lower()

		if filename == "androidmanifest.xml" then
			return "AndroidManifest"
		elseif filename == "build.xml" then
			return "AntBuildXml"
		elseif filename == "project.properties" then
			return "AntProjectPropertiesFile"
		else
			return "Content"
		end
	end)


	premake.override(vc2010.elements, "files", function(base, prj, groups)
		local elements = base(prj, groups)
		elements = table.join(elements, {
			android.androidmanifestFiles,
			android.antbuildxmlFiles,
			android.antprojectpropertiesfileFiles,
			android.contentFiles,
		})
		return elements
	end)


	function android.androidmanifestFiles(prj, groups)
		vc2010.emitFiles(prj, groups, "AndroidManifest")
	end


	function vc2010.elements.AndroidManifestFile(cfg, file)
		return {
			android.manifestSubType,
		}
	end


	function vc2010.elements.AndroidManifestFileCfg(fcfg, condition)
		return {}
	end


	function android.manifestSubType(cfg, file)
		vc2010.element("SubType", nil, "Designer")
	end


	function android.antbuildxmlFiles(prj, groups)
		vc2010.emitFiles(prj, groups, "AntBuildXml")
	end


	function vc2010.elements.AntBuildXmlFile(cfg, file)
		return {}
	end


	function vc2010.elements.AntBuildXmlFileCfg(fcfg, condition)
		return {}
	end


	function android.antprojectpropertiesfileFiles(prj, groups)
		vc2010.emitFiles(prj, groups, "AntProjectPropertiesFile")
	end


	function vc2010.elements.AntProjectPropertiesFileFile(cfg, file)
		return {}
	end


	function vc2010.elements.AntProjectPropertiesFileFileCfg(fcfg, condition)
		return {}
	end


	function android.contentFiles(prj, groups)
		vc2010.emitFiles(prj, groups, "Content")
	end


	function vc2010.elements.ContentFile(cfg, file)
		return {}
	end


	function vc2010.elements.ContentFileCfg(fcfg, condition)
		return {}
	end