--
-- visualdproj.lua
-- Generate a Visual D visualdproj project.
-- Copyright (c) 2012 Manu Evans and the Premake project
--

	premake.vstudio.visuald = { }
	local visuald = premake.vstudio.visuald
	local vstudio = premake.vstudio
	local solution = premake.solution
	local project = premake5.project
	local config = premake5.config
	local tree = premake.tree


--
-- Patch the VSTUDIO configuration with D support...
--

	local vs2010 = premake.action.list["vs2010"]
	if vs2010 ~= nil then
		table.insert( vs2010.valid_languages, premake.D )
		vs2010.valid_tools.dc = { "dmd", "gdc" }
	end

	premake.override(vs2010, "onproject", function(oldfn, prj)
		if premake.isdproject(prj) then
			premake.generate(prj, ".visualdproj", vstudio.visuald.generate)
		end

		oldfn(prj)
	end)

--
-- Generate a Visual D project, with support for the new platforms API.
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
			_p(1,'<Config name="%s" platform="%s">', premake.esc(vstudio.projectPlatform(cfg)), vstudio.solutionPlatform(cfg))

			_p(2,'<obj>0</obj>')
			_p(2,'<link>0</link>')

			local isWindows = false
			local isDebug = string.find(cfg.buildcfg, 'Debug') ~= nil
			local isOptimised = premake.config.isoptimizedbuild(cfg)

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
			_p(2,'<trace>0</trace>')
			_p(2,'<quiet>0</quiet>')
			_p(2,'<verbose>0</verbose>')
			_p(2,'<vtls>0</vtls>')
			_p(2,'<symdebug>%s</symdebug>', iif(cfg.flags.Symbols, '1', '0'))
			_p(2,'<optimize>%s</optimize>', iif(isOptimised, '1', '0'))
			_p(2,'<cpu>0</cpu>')
			_p(2,'<isX86_64>%s</isX86_64>', iif(arch == "x64", '1', '0'))
			_p(2,'<isLinux>0</isLinux>')
			_p(2,'<isOSX>0</isOSX>')
			_p(2,'<isWindows>%s</isWindows>', iif(isWindows, '1', '0'))
			_p(2,'<isFreeBSD>0</isFreeBSD>')
			_p(2,'<isSolaris>0</isSolaris>')
			_p(2,'<scheduler>0</scheduler>')
			_p(2,'<useDeprecated>0</useDeprecated>')
			_p(2,'<useAssert>0</useAssert>')
			_p(2,'<useInvariants>0</useInvariants>')
			_p(2,'<useIn>0</useIn>')
			_p(2,'<useOut>0</useOut>')
			_p(2,'<useArrayBounds>0</useArrayBounds>')
			_p(2,'<noboundscheck>0</noboundscheck>')
			_p(2,'<useSwitchError>0</useSwitchError>')
			_p(2,'<useUnitTests>0</useUnitTests>')
			_p(2,'<useInline>%s</useInline>', iif(isOptimised, '1', '0'))
			_p(2,'<release>%s</release>', iif(isDebug, '0', '1'))
			_p(2,'<preservePaths>0</preservePaths>')

			-- cfg.flags.FatalWarnings <- what do do about this?
			_p(2,'<warnings>%s</warnings>', iif(cfg.flags.NoWarnings, '0', '1'))
			_p(2,'<infowarnings>%s</infowarnings>', iif(cfg.flags.ExtraWarnings, '1', '0'))

			_p(2,'<checkProperty>0</checkProperty>')
			_p(2,'<genStackFrame>0</genStackFrame>')
			_p(2,'<pic>0</pic>')
			_p(2,'<cov>0</cov>')
			_p(2,'<nofloat>0</nofloat>')
			_p(2,'<Dversion>2</Dversion>')
			_p(2,'<ignoreUnsupportedPragmas>0</ignoreUnsupportedPragmas>')

			toolset = premake.tools[_OPTIONS.dc or "dmd"]
			_p(2,'<compiler>%s</compiler>', iif(toolset.dc == "gdc", '1', '0'))

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
			_p(2,'<doDocComments>0</doDocComments>')
			_p(2,'<docdir />')
			_p(2,'<docname />')
			_p(2,'<modules_ddoc />')
			_p(2,'<ddocfiles />')
			_p(2,'<doHdrGeneration>0</doHdrGeneration>')
			_p(2,'<hdrdir />')
			_p(2,'<hdrname />')
			_p(2,'<doXGeneration>1</doXGeneration>')
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

