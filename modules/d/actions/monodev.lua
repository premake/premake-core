--
-- monodev.lua
-- Generate a Mono-D .dproj project.
-- Copyright (c) 2012-2013 Manu Evans and the Premake project
--

	local monodevelop = premake.extensions.monodevelop
	local vstudio = premake.vstudio
	local project = premake.project
	local config = premake.config
	local fileconfig = premake.fileconfig
	local tree = premake.tree

--
-- Patch the monodevelop action with D support...
--

	local md = premake.action.list["monodevelop"]
	if md ~= nil then
		table.insert( md.valid_languages, premake.D )
		md.valid_tools.dc = { "dmd", "gdc", "ldc" }

		premake.override(md, "onproject", function(oldfn, prj)
			oldfn(prj)
			if premake.project.isd(prj) then
				premake.generate(prj, ".dproj", monodevelop.generate)
			end
		end)
	end


--
-- Patch a bunch of functions
--

	premake.override(vstudio, "projectfile", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.isd(prj) then
				return project.getfilename(prj, ".dproj")
			end
		end
		return oldfn(prj)
	end)


	premake.override(vstudio, "tool", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.isd(prj) then
				return "3947E667-4C90-4C3A-BEB9-7148D6FE0D7C"
			end
		end
		return oldfn(prj)
	end)


	premake.override(monodevelop, "getTargetGroup", function(oldfn, node, prj, groups)
		if project.isd(prj) then
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
			elseif path.isdfile(node.name) then
				return groups.Compile
--			elseif path.isdheader(node.name) then -- TODO: do .di files belong in here?
--				return groups.Include
			elseif path.isresourcefile(node.name) then
				return groups.ResourceCompile
			else
				return groups.None
			end
		else
			return oldfn(node, prj, groups)
		end
	end)


--
-- Override projectProperties element functions.
--

	premake.override(monodevelop.elements, "projectProperties", function(oldfn, prj)
		if project.isd(prj) then
			return {
				"productVersion",
				"schemaVersion",
				"projectGuid",
				"useDefaultCompiler",
				"incrementalLinking",
				"preferOneStepBuild",
--				"baseDirectory",
				"dCompiler",
				"version",
				"synchSlnVersion",
				"description",
			}
		end
		return oldfn(prj)
	end)

	function monodevelop.elements.useDefaultCompiler(prj)
		_p(2,'<UseDefaultCompiler>%s</UseDefaultCompiler>', iif(_OPTIONS.dc, 'false', 'true'))
	end

	function monodevelop.elements.incrementalLinking(prj)
		_p(2,'<IncrementalLinking>true</IncrementalLinking>')
	end

	function monodevelop.elements.preferOneStepBuild(prj)
		_p(2,'<PreferOneStepBuild>true</PreferOneStepBuild>')
	end

	function monodevelop.elements.baseDirectory(prj)
		_p(2,'<BaseDirectory>.</BaseDirectory>')
	end

	function monodevelop.elements.dCompiler(prj)
		local compiler = { dmd="DMD2", gdc="GDC", ldc="ldc2" }
		_p(2,'<Compiler>%s</Compiler>', compiler[_OPTIONS.dc or "dmd"])
	end


--
-- Override configurationProperties element functions.
--

	premake.override(monodevelop.elements, "configurationProperties", function(oldfn, cfg)
		if project.isd(cfg.project) then
			return {
				"debuginfo", -- from .cproj
				"outputPath", -- from .cproj
				"unittestMode",
				"objectsDirectory", -- TODO: should this be moved into the .cproj options?
				"debugLevel",
				"externalconsole", -- from .cproj
				"target",
				"outputName", -- from .cproj
				"dAdditionalOptions",
				"dDocDirectory",
				"versionIds",
				"debugIds",
				"additionalLinkOptions", -- from .cproj
				"additionalDependencies", -- from .cproj
				"buildEvents", -- from .cproj

--				"sourceDirectory", -- not used by D?
			}
		end
		return oldfn(cfg)
	end)

	function monodevelop.elements.unittestMode(cfg)
		-- should this be present if it's set to default?
		_p(2,'<UnittestMode>%s</UnittestMode>', iif(cfg.flags.UnitTest, 'true', 'false'))
	end

	function monodevelop.elements.objectsDirectory(cfg)
		local objdir = project.getrelative(cfg.project, cfg.objdir)
		_p(2,'<ObjectsDirectory>%s</ObjectsDirectory>', path.translate(objdir))
	end

	function monodevelop.elements.debugLevel(cfg)
		_p(2,'<DebugLevel>%d</DebugLevel>', iif(cfg.debuglevel, cfg.debuglevel, 0))
	end

	function monodevelop.elements.target(cfg)
		local map = {
			SharedLib = "SharedLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Executable",
			WindowedApp = "Executable"
		}
		_p(2,'<CompileTarget>%s</CompileTarget>', map[cfg.kind])
	end

	function monodevelop.elements.dAdditionalOptions(cfg)
		local opts = { }

		-- TODO: handle all those options, and they also need to be compiler-specific!

		-- float mode
		-- SIMD
		-- etc
		-- like this: table.insert(opts, "-msse2")

		local options
		if #opts > 0 then
			options = table.concat(opts, " ")
		end
		if #cfg.buildoptions > 0 then
			local buildOpts = table.concat(cfg.buildoptions, " ")
			options = iif(options, options .. " " .. buildOpts, buildOpts)
		end

		if options then
			_x(2,'<ExtraCompilerArguments>%s</ExtraCompilerArguments>', options)
		end
	end

	function monodevelop.elements.dDocDirectory(cfg)
		if cfg.docdir then
			local docdir = project.getrelative(cfg.project, cfg.docdir)
			_x(2,'<DDocDirectory>%s</DDocDirectory>', path.translate(docdir))
		end
	end

	function monodevelop.elements.versionIds(cfg)
		if #cfg.versionconstants > 0 then
			_x(2,'<VersionIds>')
			_x(3,'<VersionIds>')

			for _, v in ipairs(cfg.versionconstants) do
				_x(4,'<String>%s</String>', v)
			end

			_x(3,'</VersionIds>')
			_x(2,'</VersionIds>')
		end
	end

	function monodevelop.elements.debugIds(cfg)
		if #cfg.debugconstants > 0 then
			_x(2,'<DebugIds>')
			_x(3,'<DebugIds>')

			for _, d in ipairs(cfg.debugconstants) do
				_x(4,'<String>%s</String>', d)
			end

			_x(3,'</DebugIds>')
			_x(2,'</DebugIds>')
		end
	end

