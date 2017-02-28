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
				android.outDir,
			}
		else
			return oldfn(cfg)
		end
	end)


	function android.outDir(cfg)
		vc2010.element("OutDir", nil, "%s\\", cfg.buildtarget.directory)
	end


	premake.override(vc2010, "importLanguageTargets", function(oldfn, prj)
		if prj.kind == p.ANDROIDPROJ then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.targets" />')
		else
			oldfn(prj)
		end
	end)


	vc2010.categories.AndroidManifest = {
		name = "AndroidManifest",
		priority = 99,

		emitFiles = function(prj, group)
			local fileCfgFunc = {
				android.manifestSubType,
			}

			vc2010.emitFiles(prj, group, "AndroidManifest", {vc2010.generatedFile}, fileCfgFunc)
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "AndroidManifest")
		end
	}

	function android.manifestSubType(cfg, file)
		vc2010.element("SubType", nil, "Designer")
	end

	vc2010.categories.AntBuildXml = {
		name = "AntBuildXml",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "AntBuildXml", {vc2010.generatedFile})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "AntBuildXml")
		end
	}

	vc2010.categories.AntProjectPropertiesFile = {
		name = "AntProjectPropertiesFile",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "AntProjectPropertiesFile", {vc2010.generatedFile})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "AntProjectPropertiesFile")
		end
	}

	vc2010.categories.Content = {
		name = "Content",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "Content", {vc2010.generatedFile})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "Content")
		end
	}

	premake.override(vc2010, "categorizeFile", function(base, prj, file)
		if prj.kind ~= p.ANDROIDPROJ then
			return base(prj, file)
		end

		local filename = path.getname(file.name):lower()

		if filename == "androidmanifest.xml" then
			return vc2010.categories.AndroidManifest
		elseif filename == "build.xml" then
			return vc2010.categories.AntBuildXml
		elseif filename == "project.properties" then
			return vc2010.categories.AntProjectPropertiesFile
		else
			return vc2010.categories.Content
		end
	end)
