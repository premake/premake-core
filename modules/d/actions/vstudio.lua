--
-- vstudio.lua
-- Generate a VisualD .visualdproj project.
-- Copyright (c) 2012 Manu Evans and the Premake project
--

	premake.extensions.d.visuald = { }

	local d = premake.extensions.d
	local visuald = d.visuald
	local vstudio = premake.vstudio
	local solution = premake.solution
	local project = premake.project
	local config = premake.config
	local tree = premake.tree

--
-- Patch the vstudio actions with D support...
--

	for k,v in pairs({ "vs2008", "vs2010", "vs2012", "vs2013" }) do
		local vs = premake.action.list[v]
		if vs ~= nil then
			table.insert( vs.valid_languages, premake.D )
			vs.valid_tools.dc = { "dmd", "gdc", "ldc" }

			premake.override(vs, "onproject", function(oldfn, prj)
				oldfn(prj)
				if premake.project.isd(prj) then
					premake.generate(prj, ".visualdproj", visuald.generate)
				end
			end)
		end
	end


--
-- Patch a bunch of other functions
--

	premake.override(project, "isnative", function(oldfn, prj)
		return project.isd(prj) or oldfn(prj)
	end)

	premake.override(vstudio, "projectfile", function(oldfn, prj)
		if project.isd(prj) then
			return project.getfilename(prj, ".visualdproj")
		end
		return oldfn(prj)
	end)

	premake.override(vstudio, "tool", function(oldfn, prj)
		if project.isd(prj) then
			return "002A2DE9-8BB6-484D-9802-7E4AD4084715"
		end
		return oldfn(prj)
	end)


--
-- Generate a Visual D project.
--

	function visuald.generate(prj)
		io.eol = "\r\n"
		io.indent = " "

		-- for some reason Visual D projects don't seem to have an xml header
		--_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<DProject>')

		visuald.globals(prj)
		visuald.projectConfigurations(prj)
		visuald.files(prj)

		_p('</DProject>')
	end


--
-- Write out the Globals property group.
--

	function visuald.globals(prj)
		_p(1,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
	end


--
-- Write out the list of project configurations, which pairs build
-- configurations with architectures.
--

	function visuald.projectConfigurations(prj)
		-- build a list of all architectures used in this project

		for cfg in project.eachconfig(prj) do
			local prjPlatform = premake.esc(vstudio.projectPlatform(cfg))
			local slnPlatform = vstudio.solutionPlatform(cfg)
			local is64bit = slnPlatform == "x64" -- TODO: this seems like a hack

			_p(1,'<Config name="%s" platform="%s">', prjPlatform, slnPlatform)

			_p(2,'<obj>0</obj>')
			_p(2,'<link>0</link>')

			local isWindows = false
			local isDebug = string.find(cfg.buildcfg, 'Debug') ~= nil
			local isOptimised = premake.config.isOptimizedBuild(cfg)

			if cfg.kind == premake.CONSOLEAPP then
				_p(2,'<lib>0</lib>')
				_p(2,'<subsystem>1</subsystem>')
			elseif cfg.kind == premake.STATICLIB then
				_p(2,'<lib>1</lib>')
				_p(2,'<subsystem>0</subsystem>')
			elseif cfg.kind == premake.SHAREDLIB then
				_p(2,'<lib>2</lib>')
				_p(2,'<subsystem>0</subsystem>') -- SHOULD THIS BE '2' (windows)??
			else
				_p(2,'<lib>0</lib>')
				_p(2,'<subsystem>2</subsystem>')
				isWindows = true
			end

			_p(2,'<multiobj>0</multiobj>')
			_p(2,'<singleFileCompilation>0</singleFileCompilation>')
			_p(2,'<oneobj>0</oneobj>')
			_p(2,'<trace>%s</trace>', iif(cfg.flags.Profile, '1', '0'))
			_p(2,'<quiet>%s</quiet>', iif(cfg.flags.Quiet, '1', '0'))
			_p(2,'<verbose>%s</verbose>', iif(cfg.flags.Verbose, '1', '0'))
			_p(2,'<vtls>0</vtls>')
			_p(2,'<symdebug>%s</symdebug>', iif(cfg.flags.Symbols or cfg.flags.SymbolsLikeC, iif(cfg.flags.SymbolsLikeC, '2', '1'), '0'))
			_p(2,'<optimize>%s</optimize>', iif(isOptimised, '1', '0'))
			_p(2,'<cpu>0</cpu>')
			_p(2,'<isX86_64>%s</isX86_64>', iif(is64bit, '1', '0'))
			_p(2,'<isLinux>0</isLinux>')
			_p(2,'<isOSX>0</isOSX>')
			_p(2,'<isWindows>%s</isWindows>', iif(isWindows, '1', '0'))
			_p(2,'<isFreeBSD>0</isFreeBSD>')
			_p(2,'<isSolaris>0</isSolaris>')
			_p(2,'<scheduler>0</scheduler>')
			_p(2,'<useDeprecated>%s</useDeprecated>', iif(cfg.flags.Deprecated, '1', '0'))
			_p(2,'<errDeprecated>0</errDeprecated>')
			_p(2,'<useAssert>0</useAssert>')
			_p(2,'<useInvariants>0</useInvariants>')
			_p(2,'<useIn>0</useIn>')
			_p(2,'<useOut>0</useOut>')
			_p(2,'<useArrayBounds>0</useArrayBounds>')
			_p(2,'<noboundscheck>%s</noboundscheck>', iif(cfg.flags.NoBoundsCheck, '1', '0'))
			_p(2,'<useSwitchError>0</useSwitchError>')
			_p(2,'<useUnitTests>%s</useUnitTests>', iif(cfg.flags.UnitTest, '1', '0'))
			_p(2,'<useInline>%s</useInline>', iif(cfg.flags.Inline or isOptimised, '1', '0'))
			_p(2,'<release>%s</release>', iif(cfg.flags.Release or not isDebug, '1', '0'))
			_p(2,'<preservePaths>0</preservePaths>')

			-- cfg.flags.FatalWarnings <- what do do about this?
			_p(2,'<warnings>%s</warnings>', iif(cfg.warnings and cfg.warnings == "Off", '0', '1'))
			_p(2,'<infowarnings>%s</infowarnings>', iif(cfg.warnings and cfg.warnings == "Extra", '1', '0'))

			_p(2,'<checkProperty>0</checkProperty>')
			_p(2,'<genStackFrame>0</genStackFrame>')
			_p(2,'<pic>%s</pic>', iif(cfg.flags.PIC, '1', '0'))
			_p(2,'<cov>%s</cov>', iif(cfg.flags.CodeCoverage, '1', '0'))
			_p(2,'<nofloat>%s</nofloat>', iif(cfg.floatingpoint and cfg.floatingpoint == "None", '1', '0'))
			_p(2,'<Dversion>2</Dversion>')
			_p(2,'<ignoreUnsupportedPragmas>0</ignoreUnsupportedPragmas>')

			local compiler = { dmd="0", gdc="1", ldc="2" }
			_p(2,'<compiler>%s</compiler>', compiler[_OPTIONS.dc or "dmd"] or "0")

			_p(2,'<otherDMD>0</otherDMD>')
			_p(2,'<program>$(DMDInstallDir)windows\\bin\\dmd.exe</program>')

			if #cfg.includedirs > 0 then
				_p(2,'<imppath>%s</imppath>',premake.esc(table.implode(cfg.includedirs, "", "", ";")))
			else
				_p(2,'<imppath />')
			end

			_p(2,'<fileImppath />')
			local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
			_p(2,'<outdir>%s</outdir>', path.translate(outdir))
			_p(2,'<objdir>%s</objdir>', path.translate(project.getrelative(cfg.project, cfg.objdir)))
			_p(2,'<objname />')
			_p(2,'<libname />')

			_p(2,'<doDocComments>%s</doDocComments>', iif(cfg.flags.Documentation, '1', '0'))
			_p(2,'<docdir />')
			_p(2,'<docname />')
			_p(2,'<modules_ddoc />')
			_p(2,'<ddocfiles />')

			_p(2,'<doHdrGeneration>%s</doHdrGeneration>', iif(cfg.flags.GenerateHeader, '1', '0'))
			_p(2,'<hdrdir />')
			_p(2,'<hdrname />')

			_p(2,'<doXGeneration>%s</doXGeneration>', iif(cfg.flags.GenerateJSON, '1', '0'))
			_p(2,'<xfilename>$(IntDir)\\$(TargetName).json</xfilename>')

			_p(2,'<debuglevel>0</debuglevel>')
			_p(2,'<debugids />')
			_p(2,'<versionlevel>0</versionlevel>')
			if #cfg.defines > 0 then
				_p(2,'<versionids>%s</versionids>',premake.esc(table.implode(cfg.defines, "", "", ";")))
			else
				_p(2,'<versionids />')
			end

			_p(2,'<dump_source>0</dump_source>')
			_p(2,'<mapverbosity>0</mapverbosity>')
			_p(2,'<createImplib>%s</createImplib>', iif(cfg.kind ~= premake.SHAREDLIB or cfg.flags.NoImportLib, '0', '1'))
			_p(2,'<defaultlibname />')
			_p(2,'<debuglibname />')
			_p(2,'<moduleDepsFile />')

			_p(2,'<run>0</run>')
			_p(2,'<runargs />')

--			_p(2,'<runCv2pdb>%s</runCv2pdb>', iif(cfg.flags.Symbols, '1', '0'))
			_p(2,'<runCv2pdb>1</runCv2pdb>') -- we will just leave this always enabled, since it's ignored if no debuginfo is written
			_p(2,'<pathCv2pdb>$(VisualDInstallDir)cv2pdb\\cv2pdb.exe</pathCv2pdb>')
			_p(2,'<cv2pdbPre2043>0</cv2pdbPre2043>')
			_p(2,'<cv2pdbNoDemangle>0</cv2pdbNoDemangle>')
			_p(2,'<cv2pdbEnumType>0</cv2pdbEnumType>')
			_p(2,'<cv2pdbOptions />')

			_p(2,'<objfiles />')
			_p(2,'<linkswitches />')
			_p(2,'<libfiles />')
			_p(2,'<libpaths />')
			_p(2,'<deffile />')
			_p(2,'<resfile />')

			local target = config.gettargetinfo(cfg)
			_p(2,'<exefile>$(OutDir)\\%s</exefile>', target.name)

			_p(2,'<useStdLibPath>1</useStdLibPath>')

			if #cfg.buildoptions > 0 then
				local options = table.concat(cfg.buildoptions, " ")
				_p(2,'<additionalOptions>%s</additionalOptions>', options)
			else
				_p(2,'<additionalOptions />')
			end

			if #cfg.prebuildcommands > 0 then
				_p(2,'<preBuildCommand>%s</preBuildCommand>',premake.esc(table.implode(cfg.prebuildcommands, "", "", "\r\n")))
			else
				_p(2,'<preBuildCommand />')
			end

			if #cfg.postbuildcommands > 0 then
				_p(2,'<postBuildCommand>%s</postBuildCommand>',premake.esc(table.implode(cfg.postbuildcommands, "", "", "\r\n")))
			else
				_p(2,'<postBuildCommand />')
			end

			_p(2,'<filesToClean>*.obj;*.cmd;*.build;*.json;*.dep;*.o</filesToClean>')

			_p(1,'</Config>')
		end
	end


--
-- Write out the source file tree.
--

	function visuald.files(prj)
		_p(1,'<Folder name="%s">', prj.name)

		local tr = project.getsourcetree(prj)

		tree.traverse(tr, {

			-- folders, virtual or otherwise, are handled at the internal nodes
			onbranchenter = function(node, depth)
				_p(depth, '<Folder name="%s">', node.name)
			end,

			onbranchexit = function(node, depth)
				_p(depth, '</Folder>')
			end,

			-- source files are handled at the leaves
			onleaf = function(node, depth)
				_p(depth, '<File path="%s" />', path.translate(node.relpath))

--				_p(depth, '<File path="%s">', path.translate(node.relpath))
--				visuald.fileConfiguration(prj, node, depth + 1)
--				_p(depth, '</File>')
			end

		}, false, 2)

		_p(1,'</Folder>')
	end


--
-- Write out the file configuration for a given file.
--

	function visuald.fileConfiguration(prj, node, depth)

		-- maybe we'll nee this in the future...

	end

