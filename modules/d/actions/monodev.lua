--
-- d/actions/monodev.lua
-- Generate a Mono-D .dproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake
	local m = p.modules.d

	m.monod = {}

	local monodevelop = p.modules.monodevelop
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

--
-- Patch the monodevelop action with D support...
--

	local md = p.action.get("monodevelop")
	if md ~= nil then
		table.insert( md.valid_languages, p.D )
		md.valid_tools.dc = { "dmd", "gdc", "ldc" }

		p.override(md, "onProject", function(oldfn, prj)
			oldfn(prj)
			if project.isd(prj) then
				p.generate(prj, ".dproj", monodevelop.generate)
			end
		end)
	end


--
-- Patch a bunch of functions
--

	p.override(vstudio, "projectfile", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.isd(prj) then
				return p.filename(prj, ".dproj")
			end
		end
		return oldfn(prj)
	end)


	p.override(vstudio, "tool", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.isd(prj) then
				return "3947E667-4C90-4C3A-BEB9-7148D6FE0D7C"
			end
		end
		return oldfn(prj)
	end)


	p.override(monodevelop, "getTargetGroup", function(oldfn, node, prj, groups)
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

	p.override(monodevelop.elements, "projectProperties", function(oldfn, prj)
		if project.isd(prj) then
			return {
				monodevelop.cproj.projectGuid,
				m.monod.useDefaultCompiler,
				m.monod.incrementalLinking,
				m.monod.preferOneStepBuild,
--				m.monod.baseDirectory,
				m.monod.compiler,
				monodevelop.cproj.version,
				monodevelop.cproj.synchWksVersion,
				monodevelop.cproj.description,
			}
		end
		return oldfn(prj)
	end)

	function m.monod.useDefaultCompiler(prj)
		_p(2,'<UseDefaultCompiler>%s</UseDefaultCompiler>', iif(_OPTIONS.dc, 'false', 'true'))
	end

	function m.monod.incrementalLinking(prj)
		_p(2,'<IncrementalLinking>true</IncrementalLinking>')
	end

	function m.monod.preferOneStepBuild(prj)
		_p(2,'<PreferOneStepBuild>true</PreferOneStepBuild>')
	end

	function m.monod.baseDirectory(prj)
		_p(2,'<BaseDirectory>.</BaseDirectory>')
	end

	function m.monod.compiler(prj)
		local compiler = { dmd="DMD2", gdc="GDC", ldc="ldc2" }
		-- TODO: support compiler selection from 'toolset' declaration
		--       problem; toolset is at config, this is project level
		_p(2,'<Compiler>%s</Compiler>', compiler[_OPTIONS.dc or "dmd"])
	end


--
-- Override configurationProperties element functions.
--

	p.override(monodevelop.elements, "configurationProperties", function(oldfn, cfg)
		if project.isd(cfg.project) then
			return {
				monodevelop.cproj.debuginfo,
				monodevelop.cproj.outputPath,
				m.monod.unittestMode,
				m.monod.objectsDirectory, -- TODO: should this be moved into the .cproj options?
				m.monod.debugLevel,
				monodevelop.cproj.externalconsole,
				m.monod.target,
				m.monod.thirdParty,
				monodevelop.cproj.outputName,
				m.monod.additionalOptions,
				m.monod.dDocDirectory,
				m.monod.versionIds,
				m.monod.debugIds,
				monodevelop.cproj.additionalLinkOptions,
				monodevelop.cproj.additionalDependencies,
				monodevelop.cproj.buildEvents,

--				sourceDirectory, -- not used by D?
			}
		end
		return oldfn(cfg)
	end)

	function m.monod.unittestMode(cfg)
		-- should this be present if it's set to default?
		_p(2,'<UnittestMode>%s</UnittestMode>', iif(cfg.flags.UnitTest, 'true', 'false'))
	end

	function m.monod.objectsDirectory(cfg)
		local objdir = project.getrelative(cfg.project, cfg.objdir)
		_p(2,'<ObjectsDirectory>%s</ObjectsDirectory>', path.translate(objdir))
	end

	function m.monod.debugLevel(cfg)
		_p(2,'<DebugLevel>%d</DebugLevel>', iif(cfg.debuglevel, cfg.debuglevel, 0))
	end

	function m.monod.target(cfg)
		local map = {
			SharedLib = "SharedLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Executable",
			WindowedApp = "Executable"
		}
		_p(2,'<Target>%s</Target>', map[cfg.kind])
	end

	function m.monod.thirdParty(cfg)
		-- TODO: what is this for?
		local linkThirdParty = "false"
		_p(2,'<LinkinThirdPartyLibraries>%s</LinkinThirdPartyLibraries>', linkThirdParty)
	end

	function m.monod.additionalOptions(cfg)
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
			options = (options and options .. " " .. buildOpts) or buildOpts
		end

		if options then
			_x(2,'<ExtraCompilerArguments>%s</ExtraCompilerArguments>', options)
		end
	end

	function m.monod.dDocDirectory(cfg)
		if cfg.docdir then
			local docdir = project.getrelative(cfg.project, cfg.docdir)
			_x(2,'<DDocDirectory>%s</DDocDirectory>', path.translate(docdir))
		end
	end

	function m.monod.versionIds(cfg)
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

	function m.monod.debugIds(cfg)
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

