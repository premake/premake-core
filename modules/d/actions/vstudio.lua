--
-- d/actions/vstudio.lua
-- Generate a VisualD .visualdproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake
	local m = p.modules.d

	m.visuald = {}

	local vstudio = p.vstudio
	local workspace = p.workspace
	local project = p.project
	local config = p.config
	local tree = p.tree

--
-- Patch the vstudio actions with D support...
--

	for k,v in pairs({ "vs2005", "vs2008", "vs2010", "vs2012", "vs2013", "vs2015" }) do
		local vs = p.action.get(v)
		if vs ~= nil then
			table.insert( vs.valid_languages, p.D )
			vs.valid_tools.dc = { "dmd", "gdc", "ldc" }

			p.override(vs, "onProject", function(oldfn, prj)
				oldfn(prj)
				if project.isd(prj) then
					p.generate(prj, ".visualdproj", m.visuald.generate)
				end
			end)
		end
	end


--
-- Patch a bunch of other functions
--

	p.override(project, "isnative", function(oldfn, prj)
		return project.isd(prj) or oldfn(prj)
	end)

	p.override(vstudio, "projectfile", function(oldfn, prj)
		if project.isd(prj) then
			return p.filename(prj, ".visualdproj")
		end
		return oldfn(prj)
	end)

	p.override(vstudio, "tool", function(oldfn, prj)
		if project.isd(prj) then
			return "002A2DE9-8BB6-484D-9802-7E4AD4084715"
		end
		return oldfn(prj)
	end)


--
-- Generate a Visual D project.
--

	m.elements.project = function(prj)
		return {
			m.visuald.header,
			m.visuald.globals,
			m.visuald.projectConfigurations,
			m.visuald.files,
		}

	end

	function m.visuald.generate(prj)
		p.eol("\r\n")
		p.indent(" ")

		p.callArray(m.elements.project, prj)

		_p('</DProject>')
	end


	function m.visuald.header(prj)
		-- for some reason Visual D projects don't seem to have an xml header
		--_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<DProject>')
	end

	function m.visuald.globals(prj)
		_p(1,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
	end


--
-- Write out the list of project configurations, which pairs build
-- configurations with architectures.
--

	function m.visuald.projectConfigurations(prj)
		-- build a list of all architectures used in this project

		for cfg in project.eachconfig(prj) do
			local prjPlatform = p.esc(vstudio.projectPlatform(cfg))
			local slnPlatform = vstudio.solutionPlatform(cfg)
			local is64bit = slnPlatform == "x64" -- TODO: this seems like a hack

			_p(1,'<Config name="%s" platform="%s">', prjPlatform, slnPlatform)

			_p(2,'<obj>0</obj>')
			_p(2,'<link>0</link>')

			local isWindows = false
			local isDebug = string.find(cfg.buildcfg, 'Debug') ~= nil
			local isOptimised = config.isOptimizedBuild(cfg)

			if cfg.kind == p.CONSOLEAPP then
				_p(2,'<lib>0</lib>')
				_p(2,'<subsystem>1</subsystem>')
			elseif cfg.kind == p.STATICLIB then
				_p(2,'<lib>1</lib>')
				_p(2,'<subsystem>0</subsystem>')
			elseif cfg.kind == p.SHAREDLIB then
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
			_p(2,'<symdebug>%s</symdebug>', iif(cfg.symbols == p.ON or cfg.flags.SymbolsLikeC, iif(cfg.flags.SymbolsLikeC, '2', '1'), '0'))
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

			_p(2,'<warnings>%s</warnings>', iif(cfg.flags.FatalCompileWarnings, '1', '0'))
			_p(2,'<infowarnings>%s</infowarnings>', iif(cfg.warnings and cfg.warnings ~= "Off", '1', '0'))

			_p(2,'<checkProperty>0</checkProperty>')
			_p(2,'<genStackFrame>0</genStackFrame>')
			_p(2,'<pic>%s</pic>', iif(cfg.pic == "On", '1', '0'))
			_p(2,'<cov>%s</cov>', iif(cfg.flags.CodeCoverage, '1', '0'))
			_p(2,'<nofloat>%s</nofloat>', iif(cfg.floatingpoint and cfg.floatingpoint == "None", '1', '0'))
			_p(2,'<Dversion>2</Dversion>')
			_p(2,'<ignoreUnsupportedPragmas>0</ignoreUnsupportedPragmas>')

			local compiler = { dmd="0", gdc="1", ldc="2" }
			m.visuald.element(2, "compiler", compiler[_OPTIONS.dc or cfg.toolset or "dmd"])

			m.visuald.element(2, "otherDMD", '0')
			m.visuald.element(2, "program", '$(DMDInstallDir)windows\\bin\\dmd.exe')

			m.visuald.element(2, "imppath", cfg.includedirs)

			m.visuald.element(2, "fileImppath")
			m.visuald.element(2, "outdir", path.translate(project.getrelative(cfg.project, cfg.buildtarget.directory)))
			m.visuald.element(2, "objdir", path.translate(project.getrelative(cfg.project, cfg.objdir)))
			m.visuald.element(2, "objname")
			m.visuald.element(2, "libname")

			m.visuald.element(2, "doDocComments", iif(cfg.flags.Documentation, '1', '0'))
			m.visuald.element(2, "docdir", cfg.docdir)
			m.visuald.element(2, "docname", cfg.docname)
			m.visuald.element(2, "modules_ddoc")
			m.visuald.element(2, "ddocfiles")

			m.visuald.element(2, "doHdrGeneration", iif(cfg.flags.GenerateHeader, '1', '0'))
			m.visuald.element(2, "hdrdir", cfg.headerdir)
			m.visuald.element(2, "hdrname", cfg.headername)

			m.visuald.element(2, "doXGeneration", iif(cfg.flags.GenerateJSON, '1', '0'))
			m.visuald.element(2, "xfilename", '$(IntDir)\\$(TargetName).json')

			m.visuald.element(2, "debuglevel", iif(cfg.debuglevel, tostring(cfg.debuglevel), '0'))
			m.visuald.element(2, "debugids", cfg.debugconstants)
			m.visuald.element(2, "versionlevel", iif(cfg.versionlevel, tostring(cfg.versionlevel), '0'))
			m.visuald.element(2, "versionids", cfg.versionconstants)

			_p(2,'<dump_source>0</dump_source>')
			_p(2,'<mapverbosity>0</mapverbosity>')
			_p(2,'<createImplib>%s</createImplib>', iif(cfg.kind ~= p.SHAREDLIB or cfg.flags.NoImportLib, '0', '1'))
			_p(2,'<defaultlibname />')
			_p(2,'<debuglibname />')
			_p(2,'<moduleDepsFile />')

			_p(2,'<run>0</run>')
			_p(2,'<runargs />')

--			_p(2,'<runCv2pdb>%s</runCv2pdb>', iif(cfg.symbols == p.ON, '1', '0'))
			_p(2,'<runCv2pdb>1</runCv2pdb>') -- we will just leave this always enabled, since it's ignored if no debuginfo is written
			_p(2,'<pathCv2pdb>$(VisualDInstallDir)cv2pdb\\cv2pdb.exe</pathCv2pdb>')
			_p(2,'<cv2pdbPre2043>0</cv2pdbPre2043>')
			_p(2,'<cv2pdbNoDemangle>0</cv2pdbNoDemangle>')
			_p(2,'<cv2pdbEnumType>0</cv2pdbEnumType>')
			_p(2,'<cv2pdbOptions />')

			_p(2,'<objfiles />')
			_p(2,'<linkswitches />')

			local links
			local explicit = vstudio.needsExplicitLink(cfg)
			-- check to see if this project uses an external toolset. If so, let the
			-- toolset define the format of the links
			local toolset = config.toolset(cfg)
			if toolset then
				links = toolset.getlinks(cfg, not explicit)
			else
				local scope = iif(explicit, "all", "system")
				links = config.getlinks(cfg, scope, "fullpath")
			end
			m.visuald.element(2, "libfiles", table.concat(links, " "))

			m.visuald.element(2, "libpaths", cfg.libdirs)
			_p(2,'<deffile />')
			_p(2,'<resfile />')

			local target = config.gettargetinfo(cfg)
			_p(2,'<exefile>$(OutDir)\\%s</exefile>', target.name)

			_p(2,'<useStdLibPath>1</useStdLibPath>')

			local runtime = 0
			if not cfg.flags.OmitDefaultLibrary then
				if config.isDebugBuild(cfg) then
					runtime = iif(cfg.flags.StaticRuntime, "2", "4")
				else
					runtime = iif(cfg.flags.StaticRuntime, "1", "3")
				end
			end
			m.visuald.element(2, "cRuntime", runtime)

			local additionalOptions
			if #cfg.buildoptions > 0 then
				additionalOptions = table.concat(cfg.buildoptions, " ")
			end
			if #cfg.linkoptions > 0 then
				local linkOpts = table.implode(cfg.linkoptions, "-L", "", " ")
				if additionalOptions then
					additionalOptions = additionalOptions .. " " .. linkOpts
				else
					additionalOptions = linkOpts
				end
			end
			m.visuald.element(2, "additionalOptions", additionalOptions)

			if #cfg.prebuildcommands > 0 then
				_p(2,'<preBuildCommand>%s</preBuildCommand>',p.esc(table.implode(cfg.prebuildcommands, "", "", "\r\n")))
			else
				_p(2,'<preBuildCommand />')
			end

			if #cfg.postbuildcommands > 0 then
				_p(2,'<postBuildCommand>%s</postBuildCommand>',p.esc(table.implode(cfg.postbuildcommands, "", "", "\r\n")))
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

	function m.visuald.files(prj)
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
--				m.visuald.fileConfiguration(prj, node, depth + 1)
--				_p(depth, '</File>')
			end

		}, false, 2)

		_p(1,'</Folder>')
	end

	function m.visuald.fileConfiguration(prj, node, depth)

		-- maybe we'll need this in the future...

	end


--
-- Output an individual project XML element.
--

	function m.visuald.element(depth, name, value, ...)
		local isTable = type(value) == "table"
		if not value or (isTable and #value == 0) then
			_p(depth, '<%s />', name)
		else
			if isTable then
				value = p.esc(table.implode(value, "", "", ";"))
				_p(depth, '<%s>%s</%s>', name, value, name)
			else
				if select('#',...) == 0 then
					value = p.esc(value)
				end
				_x(depth, string.format('<%s>%s</%s>', name, value, name), ...)
			end
		end
	end
