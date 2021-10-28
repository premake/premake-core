--
-- Name:        codelite/codelite_project.lua
-- Purpose:     Generate a CodeLite C/C++ project file.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Manu Evans
--              Tom van Dijck
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2016 Jason Perkins and the Premake project
--

	local p = premake
	local tree = p.tree
	local project = p.project
	local config = p.config
	local codelite = p.modules.codelite

	codelite.project = {}
	local m = codelite.project


	function codelite.getLinks(cfg)
		-- System libraries are undecorated, add the required extension
		return config.getlinks(cfg, "system", "fullpath")
	end

	function codelite.getSiblingLinks(cfg)
		-- If we need sibling projects to be listed explicitly, add them on
		return config.getlinks(cfg, "siblings", "fullpath")
	end


	m.elements = {}

	m.ctools = {
		gcc = "gnu gcc",
		clang = "clang",
		msc = "Visual C++",
	}
	m.cxxtools = {
		gcc = "gnu g++",
		clang = "clang++",
		msc = "Visual C++",
	}

	function m.getcompilername(cfg)
		local tool = _OPTIONS.cc or cfg.toolset or p.CLANG

		local toolset = p.tools[tool]
		if not toolset then
			error("Invalid toolset '" + (_OPTIONS.cc or cfg.toolset) + "'")
		end

		if p.languages.isc(cfg.language) then
			return m.ctools[tool]
		elseif p.languages.iscpp(cfg.language) then
			return m.cxxtools[tool]
		end
	end

	function m.getcompiler(cfg)
		local toolset = p.tools[_OPTIONS.cc or cfg.toolset or p.CLANG]
		if not toolset then
			error("Invalid toolset '" + (_OPTIONS.cc or cfg.toolset) + "'")
		end
		return toolset
	end

	local function configuration_iscustombuild(cfg)

		return cfg and (cfg.kind == p.MAKEFILE) and (#cfg.buildcommands > 0)
	end

	local function configuration_isfilelist(cfg)

		return cfg and (cfg.buildaction == "None") and not configuration_iscustombuild(cfg)
	end

	local function configuration_needresoptions(cfg)

		return cfg and config.findfile(cfg, ".rc") and not configuration_iscustombuild(cfg)
	end


	m.internalTypeMap = {
		ConsoleApp = "Console",
		WindowedApp = "Console",
		Makefile = "",
		SharedLib = "Library",
		StaticLib = "Library"
	}

	function m.header(prj)
		_p('<?xml version="1.0" encoding="UTF-8"?>')

		local type = m.internalTypeMap[prj.kind] or ""
		_x('<CodeLite_Project Name="%s" InternalType="%s">', prj.name, type)
	end

	function m.plugins(prj)
--		_p(1, '<Plugins>')
			-- <Plugin Name="CMakePlugin">
			-- <Plugin Name="qmake">
--		_p(1, '</Plugins>')

		_p(1, '<Plugins/>')
	end

	function m.description(prj)
		_p(1, '<Description/>')

		-- TODO: ...
	end

	function m.files(prj)
		local tr = project.getsourcetree(prj)
		tree.traverse(tr, {
			-- folders are handled at the internal nodes
			onbranchenter = function(node, depth)
				_p(depth, '<VirtualDirectory Name="%s">', node.name)
			end,
			onbranchexit = function(node, depth)
				_p(depth, '</VirtualDirectory>')
			end,
			-- source files are handled at the leaves
			onleaf = function(node, depth)
				local excludesFromBuild = {}
				for cfg in project.eachconfig(prj) do
					local cfgname = codelite.cfgname(cfg)
					local fcfg = p.fileconfig.getconfig(node, cfg)
					if not fcfg or fcfg.flags.ExcludeFromBuild then
						table.insert(excludesFromBuild, cfgname)
					end
				end

				if #excludesFromBuild > 0 then
					_p(depth, '<File Name="%s" ExcludeProjConfig="%s" />', node.relpath, table.concat(excludesFromBuild, ';'))
				else
					_p(depth, '<File Name="%s"/>', node.relpath)
				end
			end,
		}, true)
	end

	function m.dependencies(prj)

		-- TODO: dependencies don't emit a line for each config if there aren't any...

--		_p(1, '<Dependencies/>')

		local dependencies = project.getdependencies(prj)
		for cfg in project.eachconfig(prj) do
			cfgname = codelite.cfgname(cfg)
			if #dependencies > 0 then
				_p(1, '<Dependencies Name="%s">', cfgname)
					for _, dependency in ipairs(dependencies) do
						_p(2, '<Project Name="%s"/>', dependency.name)
					end
				_p(1, '</Dependencies>')
			else
				_p(1, '<Dependencies Name="%s"/>', cfgname)
			end
		end
	end


	function m.global_compiler(prj)
		_p(3, '<Compiler Options="" C_Options="" Assembler="">')
		_p(4, '<IncludePath Value="."/>')
		_p(3, '</Compiler>')
	end

	function m.global_linker(prj)
		_p(3, '<Linker Options="">')
		_p(4, '<LibraryPath Value="."/>')
		_p(3, '</Linker>')
	end

	function m.global_resourceCompiler(prj)
		_p(3, '<ResourceCompiler Options=""/>')
	end

	m.elements.globalSettings = function(prj)
		return {
			m.global_compiler,
			m.global_linker,
			m.global_resourceCompiler,
		}
	end

	function m.compiler(cfg)
		if configuration_iscustombuild(cfg) or configuration_isfilelist(cfg) then
			_p(3, '<Compiler Required="no"/>')
			return
		end

		local toolset = m.getcompiler(cfg)
		local sysincludedirs = toolset.getincludedirs(cfg, {}, cfg.sysincludedirs, cfg.frameworkdirs)
		local forceincludes = toolset.getforceincludes(cfg)
		local cxxflags = table.concat(table.join(sysincludedirs, toolset.getcxxflags(cfg), forceincludes, cfg.buildoptions), ";")
		local cflags   = table.concat(table.join(sysincludedirs, toolset.getcflags(cfg), forceincludes, cfg.buildoptions), ";")
		local asmflags = ""
		local pch      = p.tools.gcc.getpch(cfg)
		local usepch   = "yes"
		if pch == nil then
			pch = "";
			usepch = "no"
		end

		_x(3, '<Compiler Options="%s" C_Options="%s" Assembler="%s" Required="yes" PreCompiledHeader="%s" PCHInCommandLine="%s" UseDifferentPCHFlags="no" PCHFlags="">', cxxflags, cflags, asmflags, pch, usepch)

		for _, includedir in ipairs(cfg.includedirs) do
			_x(4, '<IncludePath Value="%s"/>', project.getrelative(cfg.project, includedir))
		end
		for _, define in ipairs(cfg.defines) do
			_p(4, '<Preprocessor Value="%s"/>', p.esc(define):gsub(' ', '\\ '))
		end
		_p(3, '</Compiler>')
	end

	function m.linker(cfg)
		if configuration_iscustombuild(cfg) or configuration_isfilelist(cfg) then
			_p(3, '<Linker Required="no"/>')
			return
		end

		local toolset = m.getcompiler(cfg)
		local flags   = table.join(toolset.getldflags(cfg), toolset.getincludedirs(cfg, {}, nil, cfg.frameworkdirs), toolset.getrunpathdirs(cfg, table.join(cfg.runpathdirs, config.getsiblingtargetdirs(cfg))), cfg.linkoptions, toolset.getlinks(cfg))

		_x(3, '<Linker Required="yes" Options="%s">', table.concat(flags, ";"))

		for _, libdir in ipairs(cfg.libdirs) do
			_p(4, '<LibraryPath Value="%s"/>', project.getrelative(cfg.project, libdir))
		end
		_p(3, '</Linker>')
	end

	function m.resourceCompiler(cfg)
		if not configuration_needresoptions(cfg) then
			_p(3, '<ResourceCompiler Options="" Required="no"/>')
			return
		end

		local toolset = m.getcompiler(cfg)
		local defines = table.implode(toolset.getdefines(table.join(cfg.defines, cfg.resdefines)), "", ";", "")
		local options = table.concat(cfg.resoptions, ";")

		_x(3, '<ResourceCompiler Options="%s%s" Required="yes">', defines, options)
		for _, includepath in ipairs(table.join(cfg.sysincludedirs, cfg.includedirs, cfg.resincludedirs)) do
			_x(4, '<IncludePath Value="%s"/>', project.getrelative(cfg.project, includepath))
		end
		_p(3, '</ResourceCompiler>')
	end

	function m.general(cfg)
		if configuration_isfilelist(cfg) then
			_p(3, '<General IntermediateDirectory="." WorkingDirectory="." PauseExecWhenProcTerminates="no"/>')
			return
		end

		local prj = cfg.project

		local isExe = prj.kind == "WindowedApp" or prj.kind == "ConsoleApp"
		local targetpath = project.getrelative(prj, cfg.buildtarget.directory)
		local objdir     = project.getrelative(prj, cfg.objdir)
		local targetname = project.getrelative(prj, cfg.buildtarget.abspath)
		local workingdir = cfg.debugdir or prj.location
		local command    = iif(isExe, path.getrelative(workingdir, cfg.buildtarget.abspath), "")
		local cmdargs    = iif(isExe, table.concat(cfg.debugargs, " "), "") -- TODO: should this be debugargs instead?
		local useseparatedebugargs = "no"
		local debugargs  = ""
		local workingdir = iif(isExe, project.getrelative(prj, cfg.debugdir), "")
		local pauseexec  = iif(prj.kind == "ConsoleApp", "yes", "no")
		local isguiprogram = iif(prj.kind == "WindowedApp", "yes", "no")
		local isenabled  = iif(cfg.flags.ExcludeFromBuild, "no", "yes")

		_x(3, '<General OutputFile="%s" IntermediateDirectory="%s" Command="%s" CommandArguments="%s" UseSeparateDebugArgs="%s" DebugArguments="%s" WorkingDirectory="%s" PauseExecWhenProcTerminates="%s" IsGUIProgram="%s" IsEnabled="%s"/>',
			targetname, objdir, command, cmdargs, useseparatedebugargs, debugargs, workingdir, pauseexec, isguiprogram, isenabled)
	end

	function m.environment(cfg)
		local envs = table.concat(cfg.debugenvs, "\n")

		_p(3, '<Environment EnvVarSetName="&lt;Use Defaults&gt;" DbgSetName="&lt;Use Defaults&gt;">')
		_p(4, '<![CDATA[%s]]>', envs)
		_p(3, '</Environment>')
	end

	function m.debugger(cfg)

		_p(3, '<Debugger IsRemote="%s" RemoteHostName="%s" RemoteHostPort="%s" DebuggerPath="" IsExtended="%s">', iif(cfg.debugremotehost, "yes", "no"), cfg.debugremotehost or "", iif(cfg.debugport, tostring(cfg.debugport), ""), iif(cfg.debugextendedprotocol, "yes", "no"))
		if #cfg.debugsearchpaths > 0 then
			p.escaper(codelite.escElementText)
			_p(4, '<DebuggerSearchPaths>%s</DebuggerSearchPaths>', table.concat(p.esc(project.getrelative(cfg.project, cfg.debugsearchpaths)), "\n"))
			p.escaper(codelite.esc)
		else
			_p(4, '<DebuggerSearchPaths/>')
		end
		if #cfg.debugconnectcommands > 0 then
			p.escaper(codelite.escElementText)
			_p(4, '<PostConnectCommands>%s</PostConnectCommands>', table.concat(p.esc(cfg.debugconnectcommands), "\n"))
			p.escaper(codelite.esc)
		else
			_p(4, '<PostConnectCommands/>')
		end
		if #cfg.debugstartupcommands > 0 then
			p.escaper(codelite.escElementText)
			_p(4, '<StartupCommands>%s</StartupCommands>', table.concat(p.esc(cfg.debugstartupcommands), "\n"))
			p.escaper(codelite.esc)
		else
			_p(4, '<StartupCommands/>')
		end
		_p(3, '</Debugger>')
	end

	function m.preBuild(cfg)
		if #cfg.prebuildcommands > 0 or cfg.prebuildmessage then
			_p(3, '<PreBuild>')
			p.escaper(codelite.escElementText)
			if cfg.prebuildmessage then
				local command = os.translateCommandsAndPaths("@{ECHO} " .. cfg.prebuildmessage, cfg.project.basedir, cfg.project.location)
				_x(4, '<Command Enabled="yes">%s</Command>', command)
			end
			local commands = os.translateCommandsAndPaths(cfg.prebuildcommands, cfg.project.basedir, cfg.project.location)
			for _, command in ipairs(commands) do
				_x(4, '<Command Enabled="yes">%s</Command>', command)
			end
			p.escaper(codelite.esc)
			_p(3, '</PreBuild>')
		end
	end

	function m.postBuild(cfg)
		if #cfg.postbuildcommands > 0  or cfg.postbuildmessage then
			_p(3, '<PostBuild>')
			p.escaper(codelite.escElementText)
			if cfg.postbuildmessage then
				local command = os.translateCommandsAndPaths("@{ECHO} " .. cfg.postbuildmessage, cfg.project.basedir, cfg.project.location)
				_x(4, '<Command Enabled="yes">%s</Command>', command)
			end
			local commands = os.translateCommandsAndPaths(cfg.postbuildcommands, cfg.project.basedir, cfg.project.location)
			for _, command in ipairs(commands) do
				_x(4, '<Command Enabled="yes">%s</Command>', command)
			end
			p.escaper(codelite.esc)
			_p(3, '</PostBuild>')
		end
	end

	function m.customBuild(cfg)
		if not configuration_iscustombuild(cfg) then
			_p(3, '<CustomBuild Enabled="no"/>')
			return
		end

		local build   = table.implode(cfg.buildcommands,"","","")
		local clean   = table.implode(cfg.cleancommands,"","","")
		local rebuild = table.implode(cfg.rebuildcommands,"","","")

		_p(3, '<CustomBuild Enabled="yes">')
		_x(4, '<BuildCommand>%s</BuildCommand>', build)
		_x(4, '<CleanCommand>%s</CleanCommand>', clean)
		_x(4, '<RebuildCommand>%s</RebuildCommand>', rebuild)
		_p(4, '<PreprocessFileCommand></PreprocessFileCommand>')
		_p(4, '<SingleFileCommand></SingleFileCommand>')
		_p(4, '<MakefileGenerationCommand></MakefileGenerationCommand>')
		_p(4, '<ThirdPartyToolName></ThirdPartyToolName>')
		_p(4, '<WorkingDirectory></WorkingDirectory>')
		_p(3, '</CustomBuild>')
	end

	function m.additionalRules(cfg)
		if configuration_iscustombuild(cfg) then
			_p(3, '<AdditionalRules/>')
			return
		end

		_p(3, '<AdditionalRules>')
		_p(4, '<CustomPostBuild/>')

		local dependencies = {}
		local makefilerules = {}
		local function addrule(dependencies, makefilerules, config, filename)
			if #config.buildcommands == 0 or #config.buildOutputs == 0 then
				return false
			end
			local inputs = table.implode(project.getrelative(cfg.project, config.buildInputs), "", "", " ")
			if filename ~= "" and inputs ~= "" then
				filename = filename .. " "
			end
			local outputs = project.getrelative(cfg.project, config.buildOutputs[1])
			local buildmessage = ""
			if config.buildmessage then
				buildmessage = "\t@{ECHO} " .. config.buildmessage .. "\n"
			end
			local commands = table.implode(config.buildCommands,"\t","\n","")
			table.insert(makefilerules, os.translateCommandsAndPaths(outputs .. ": " .. filename .. inputs .. "\n" .. buildmessage .. commands, cfg.project.basedir, cfg.project.location))
			table.insertflat(dependencies, outputs)
			return true
		end
		local tr = project.getsourcetree(cfg.project)
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				local filecfg = p.fileconfig.getconfig(node, cfg)
				local prj = cfg.project
				local rule = p.global.getRuleForFile(node.name, prj.rules)

				if not addrule(dependencies, makefilerules, filecfg, node.relpath) and rule then
					local environ = table.shallowcopy(filecfg.environ)

					if rule.propertydefinition then
						p.rule.prepareEnvironment(rule, environ, cfg)
						p.rule.prepareEnvironment(rule, environ, filecfg)
					end
					local rulecfg = p.context.extent(rule, environ)
					addrule(dependencies, makefilerules, rulecfg, node.relpath)
				end
			end
		})
		addrule(dependencies, makefilerules, cfg, "")

		if #makefilerules == 0 and #dependencies == 0 then
			_p(4, '<CustomPreBuild/>')
		else
			_p(4, '<CustomPreBuild>' .. table.implode(dependencies,"",""," "))
			_p(0, table.implode(makefilerules,"","","\n") .. '</CustomPreBuild>')
		end
		_p(3, '</AdditionalRules>')
	end

	function m.isCpp11(cfg)
		return (cfg.cppdialect == 'gnu++11') or (cfg.cppdialect == 'C++11') or (cfg.cppdialect == 'gnu++0x') or (cfg.cppdialect == 'C++0x')
	end

	function m.isCpp14(cfg)
		return (cfg.cppdialect == 'gnu++14') or (cfg.cppdialect == 'C++14') or (cfg.cppdialect == 'gnu++1y') or (cfg.cppdialect == 'C++1y')
	end

	function m.completion(cfg)
		_p(3, '<Completion EnableCpp11="%s" EnableCpp14="%s">',
			iif(m.isCpp11(cfg), "yes", "no"),
			iif(m.isCpp14(cfg), "yes", "no")
		)
		_p(4, '<ClangCmpFlagsC/>')
		_p(4, '<ClangCmpFlags/>')
		_p(4, '<ClangPP/>') -- TODO: we might want to set special code completion macros...?
		_p(4, '<SearchPaths/>') -- TODO: search paths for code completion?
		_p(3, '</Completion>')
	end

	m.elements.settings = function(cfg)
		return {
			m.compiler,
			m.linker,
			m.resourceCompiler,
			m.general,
			m.environment,
			m.debugger,
			m.preBuild,
			m.postBuild,
			m.customBuild,
			m.additionalRules,
			m.completion,
		}
	end

	m.types =
	{
		ConsoleApp  = "Executable",
		Makefile    = "",
		SharedLib   = "Dynamic Library",
		StaticLib   = "Static Library",
		WindowedApp = "Executable",
		Utility     = "",
	}

	m.debuggers =
	{
		Default = "GNU gdb debugger",
		GDB = "GNU gdb debugger",
		LLDB = "LLDB Debugger",
	}

	function m.settings(prj)
		_p(1, '<Settings Type="%s">', m.types[prj.kind] or "")

		_p(2, '<GlobalSettings>')
		p.callArray(m.elements.globalSettings, prj)
		_p(2, '</GlobalSettings>')

		for cfg in project.eachconfig(prj) do

			local cfgname  = codelite.cfgname(cfg)
			local compiler = m.getcompilername(cfg)
			local debugger = m.debuggers[cfg.debugger] or m.debuggers.Default
			local type = m.types[cfg.kind]

			_x(2, '<Configuration Name="%s" CompilerType="%s" DebuggerType="%s" Type="%s" BuildCmpWithGlobalSettings="append" BuildLnkWithGlobalSettings="append" BuildResWithGlobalSettings="append">', cfgname, compiler, debugger, type)

			p.callArray(m.elements.settings, cfg)

			_p(2, '</Configuration>')
		end

		_p(1, '</Settings>')
	end


	m.elements.project = function(prj)
		return {
			m.header,
			m.plugins,
			m.description,
			m.files,
			m.dependencies,
			m.settings,
		}
	end

--
-- Project: Generate the CodeLite project file.
--
	function m.generate(prj)
		p.utf8()

		p.callArray(m.elements.project, prj)

		_p('</CodeLite_Project>')
	end
