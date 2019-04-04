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
		if prj.kind == p.PACKAGING then
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
		if prj.kind == p.PACKAGING then
			return premake.filename(prj, ".androidproj")
		else
			return oldfn(prj)
		end
	end)


	premake.override(vstudio, "tool", function(oldfn, prj)
		if prj.kind == p.PACKAGING then
			return "39E2626F-3545-4960-A6E8-258AD8476CE5"
		else
			return oldfn(prj)
		end
	end)


	premake.override(vc2010.elements, "globals", function (oldfn, cfg)
		local elements = oldfn(cfg)

		if cfg.kind == premake.PACKAGING then
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
		if cfg.kind == p.PACKAGING then
			elements = {
				android.androidAPILevel,
				vc2010.useDebugLibraries,
			}
		end
		return elements
	end)


	premake.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind == p.PACKAGING then
			elements = {
				android.antPackage,
			}
		end
		return elements
	end)


	premake.override(vc2010, "importDefaultProps", function(oldfn, prj)
		if prj.kind == p.PACKAGING then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.Default.props" />')
		else
			oldfn(prj)
		end
	end)


	premake.override(vc2010, "importLanguageSettings", function(oldfn, prj)
		if prj.kind == p.PACKAGING then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.props" />')
		else
			oldfn(prj)
		end
	end)


	premake.override(vc2010, "propertySheets", function(oldfn, cfg)
		if cfg.kind ~= p.PACKAGING then
			oldfn(cfg)
		end
	end)


	premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
		if cfg.kind == p.PACKAGING then
			return {
				android.outDir,
				vc2010.intDir,
				vc2010.targetName,
			}
		else
			return oldfn(cfg)
		end
	end)


	function android.outDir(cfg)
		vc2010.element("OutDir", nil, "%s\\", cfg.buildtarget.directory)
	end


	premake.override(vc2010, "importLanguageTargets", function(oldfn, prj)
		if prj.kind == p.PACKAGING then
			p.w('<Import Project="$(AndroidTargetsPath)\\Android.targets" />')
		else
			oldfn(prj)
		end
	end)

	function android.link(cfg, file)
		-- default the seperator to '/' as that is what is searched for
		-- below. Otherwise the function will use target seperator which
		-- could be '\\' and result in failure to create links.
		local fname = path.translate(file.relpath, '/')

		-- Files that live outside of the project tree need to be "linked"
		-- and provided with a project relative pseudo-path. Check for any
		-- leading "../" sequences and, if found, remove them and mark this
		-- path as external.
		local link, count = fname:gsub("%.%.%/", "")
		local external = (count > 0) or fname:find(':', 1, true) or (file.vpath and file.vpath ~= file.relpath)

		-- Try to provide a little bit of flexibility by allowing virtual
		-- paths for external files. Would be great to support them for all
		-- files but Visual Studio chokes if file is already in project area.
		if external and file.vpath ~= file.relpath then
			link = file.vpath
		end

		if external then
			vc2010.element("Link", nil, path.translate(link))
		end
	end


	vc2010.categories.AndroidManifest = {
		name = "AndroidManifest",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "AndroidManifest", {vc2010.generatedFile, android.link, android.manifestSubType})
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
			vc2010.emitFiles(prj, group, "AntBuildXml", {vc2010.generatedFile, android.link})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "AntBuildXml")
		end
	}

	vc2010.categories.AntProjectPropertiesFile = {
		name = "AntProjectPropertiesFile",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "AntProjectPropertiesFile", {vc2010.generatedFile, android.link})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "AntProjectPropertiesFile")
		end
	}

	vc2010.categories.JavaCompile = {
		name = "JavaCompile",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "JavaCompile", {vc2010.generatedFile, android.link})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "JavaCompile")
		end
	}

	vc2010.categories.Content = {
		name = "Content",
		priority = 99,

		emitFiles = function(prj, group)
			vc2010.emitFiles(prj, group, "Content", {vc2010.generatedFile, android.link})
		end,

		emitFilter = function(prj, group)
			vc2010.filterGroup(prj, group, "Content")
		end
	}

	premake.override(vc2010, "categorizeFile", function(base, prj, file)
		if prj.kind ~= p.PACKAGING then
			return base(prj, file)
		end

		local filename = path.getname(file.name):lower()
		local extension = path.getextension(filename)

		if filename == "androidmanifest.xml" then
			return vc2010.categories.AndroidManifest
		elseif filename == "build.xml" then
			return vc2010.categories.AntBuildXml
		elseif filename == "project.properties" then
			return vc2010.categories.AntProjectPropertiesFile
		elseif extension == ".java" then
			return vc2010.categories.JavaCompile
		else
			return vc2010.categories.Content
		end
	end)
