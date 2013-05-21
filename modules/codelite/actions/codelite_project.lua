--
-- Name:        actions/codelite_project.lua
-- Purpose:     Generate a CodeLite C/C++ project file.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato (new v5 API)
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2013 Jason Perkins and the Premake project
--
	local tree     = premake.tree
	local project  = premake5.project
	local codelite = premake.extensions.codelite

	codelite.types =
	{ 
		ConsoleApp  = "Executable",
		Makefile    = "",
		SharedLib   = "Dynamic Library",
		StaticLib   = "Static Library",
		WindowedApp = "Executable"
	}
--
--   TODO: Manage project description
--
	local function project_description(prj)

		_p(1, '<Description/>')
	end

	local function project_files(prj)

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
				_p(depth, '<File Name="%s"/>', node.relpath)
			end,
		}, false, 1)
	end
--
--   TODO: Manage global settings
--
	local function project_globalsettings(prj)

		_p(2, '<GlobalSettings>')
		_p(3, '<Compiler Options="" C_Options=""/>')
		_p(3, '<Linker Options=""/>')
		_p(3, '<ResourceCompiler Options=""/>')
		_p(2, '</GlobalSettings>')
	end

	local config = premake5.config

	local function configuration_iscustombuild(cfg)

		return cfg and (cfg.kind == premake.MAKEFILE) and (#cfg.buildcommands > 0)
	end

	local function configuration_isfilelist(cfg)

		return cfg and (cfg.buildaction == "None") and not configuration_iscustombuild(cfg)
	end

	local function configuration_needresoptions(cfg)

		return cfg and premake.findfile(cfg,".rc") and not configuration_iscustombuild(cfg)
	end

	local function configuration_targetoptions(prj, cfg)

		if configuration_isfilelist(cfg) then
			_p(3, '<General IntermediateDirectory="." WorkingDirectory="." PauseExecWhenProcTerminates="no"/>')
			return
		end

		local targetpath = premake.esc(cfg.buildtarget.relpath)
		local objdir     = premake.esc(project.getrelative(prj, cfg.objdir))
		local targetname = premake.esc(project.getrelative(prj, cfg.buildtarget.name))
		local cmdargs    = table.concat(cfg.debugargs, " ") or ""
		local targetdir  = premake.esc(project.getrelative(prj, cfg.buildtarget.directory))
		local pauseexec  = "yes" -- iif(cfg.kind == "WindowedApp", "no", "yes")

		_p(3, '<General OutputFile="%s" IntermediateDirectory="%s" Command="%s" CommandArguments="%s" WorkingDirectory="%s" PauseExecWhenProcTerminates="%s"/>',
			targetpath, objdir, targetname, cmdargs, targetdir, pauseexec)
	end
--
-- TODO: Use differently c and cxx flags.
--       Currently using cflags as in old codelite action script.
--
	local function configuration_buildoptions(cfg)

		if configuration_iscustombuild(cfg) or configuration_isfilelist(cfg) then
			_p(3, '<Compiler Required="no"/>')
			return
		end

		local cc       = codelite.compiler
		local cxxflags = table.concat(premake.esc(table.join(cc.getcxxflags(cfg), cfg.buildoptions)), ";")
		local cflags   = table.concat(premake.esc(table.join(cc.getcflags(cfg),   cfg.buildoptions)), ";")

		_p(3, '<Compiler Options="%s" C_Options="%s" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">',
			cflags, cflags)

		for _, includedir in ipairs(cfg.includedirs) do
			_p(4, '<IncludePath Value="%s"/>',
			premake.esc(project.getrelative(cfg.project, includedir)))
		end
		for _, define in ipairs(cfg.defines) do
			_p(4, '<Preprocessor Value="%s"/>', premake.esc(define))
		end
		_p(3, '</Compiler>')
	end

	local function configuration_linkoptions(cfg)

		if configuration_iscustombuild(cfg) or configuration_isfilelist(cfg) then
			_p(3, '<Linker Required="no"/>')
			return
		end

		local cc      = codelite.compiler
		local ldflags = premake.esc(table.join(cc.getldflags(cfg), cfg.linkoptions))

		_p(3, '<Linker Required="yes" Options="%s">', table.concat(ldflags, ";"))
		for _, libpath in ipairs(cc.getlinks(cfg, "all", "directory")) do
			_p(4, '<LibraryPath Value="%s" />', premake.esc(libpath))
		end
		for _, libname in ipairs(cc.getlinks(cfg, "all", "basename")) do
			_p(4, '<Library Value="%s" />', premake.esc(libname))
		end
		_p(3, '</Linker>')
	end

	local function configuration_resoptions(cfg)

		if not configuration_needresoptions(cfg) then
			_p(3, '<ResourceCompiler Required="no"/>')
			return
		end

		local defines = table.implode(table.join(cfg.defines, cfg.resdefines), "-D", ";", "")
		local options = table.concat(cfg.resoptions, ";")

		_p(3, '<ResourceCompiler Required="yes" Options="%s%s">', defines, options)
		for _, includepath in ipairs(table.join(cfg.includedirs, cfg.resincludedirs)) do
			_p(4, '<IncludePath Value="%s"/>', premake.esc(includepath))
		end
		_p(3, '</ResourceCompiler>')
	end
--
--   TODO: Manage build rules
--
	local function configuration_buildrules(cfg)

		if configuration_iscustombuild(cfg) then
			_p(3, '<AdditionalRules/>')
			return
		end

		_p(3, '<AdditionalRules>')
		_p(4, '<CustomPostBuild/>')
		_p(4, '<CustomPreBuild/>')
		_p(3, '</AdditionalRules>')
	end
--
--   TODO: Manage environment options
--
	local function configuration_environment(prj, cfg)

		_p(3, '<Environment EnvVarSetName="&lt;Use Defaults&gt;" DbgSetName="&lt;Use Defaults&gt;">')
		_p(4, '<![CDATA[]]>')
		_p(3, '</Environment>')
	end
--
--   TODO: Manage remote debugger
--
	local function configuration_debugger(prj, cfg)

		_p(3, '<Debugger IsRemote="no" RemoteHostName="" RemoteHostPort="" DebuggerPath="">')
		_p(4, '<PostConnectCommands/>')
		_p(4, '<StartupCommands/>')
		_p(3, '</Debugger>')
	end

	local function configuration_prebuildcommands(prj, cfg)

		if #cfg.prebuildcommands > 0 then
			_p(3, '<PreBuild>')
			for _, commands in ipairs(cfg.prebuildcommands) do
				_p(4, '<Command Enabled="yes">%s</Command>',
				premake.esc(commands))
			end
			_p(3, '</PreBuild>')
		end
	end

	local function configuration_postbuildcommands(prj, cfg)

		if #cfg.postbuildcommands > 0 then
			_p(3, '<PostBuild>')
			for _, commands in ipairs(cfg.postbuildcommands) do
				_p(4, '<Command Enabled="yes">%s</Command>',
				premake.esc(commands))
			end
			_p(3, '</PostBuild>')
		end
	end
--
--   TODO: Manage (c++11) code completion
--
	local function configuration_codecompletion(prj, cfg)

		_p(3, '<Completion EnableCpp11="no">')
		_p(4, '<ClangCmpFlagsC/>')
		_p(4, '<ClangCmpFlags/>')
		_p(4, '<ClangPP/>')
		_p(4, '<SearchPaths/>')
		_p(3, '</Completion>')
	end

	local function configuration_custombuild(prj, cfg)

		if not configuration_iscustombuild(cfg) then
			_p(3, '<CustomBuild Enabled="no"/>')
			return
		end

		local build   = premake.esc(table.implode(cfg.buildcommands,"","",""))
		local clean   = premake.esc(table.implode(cfg.cleancommands,"","",""))
		local rebuild = premake.esc(table.implode(cfg.rebuildcommands,"","",""))

		_p(3, '<CustomBuild Enabled="yes">')
		_p(4, '<BuildCommand>%s</BuildCommand>', build)
		_p(4, '<CleanCommand>%s</CleanCommand>', clean)
		_p(4, '<RebuildCommand>%s</RebuildCommand>', rebuild)
		_p(4, '<PreprocessFileCommand></PreprocessFileCommand>')
		_p(4, '<SingleFileCommand></SingleFileCommand>')
		_p(4, '<MakefileGenerationCommand></MakefileGenerationCommand>')
		_p(4, '<ThirdPartyToolName></ThirdPartyToolName>')
		_p(4, '<WorkingDirectory></WorkingDirectory>')
		_p(3, '</CustomBuild>')
	end

	local function getcompilername(cfg)

		if _OPTIONS.cc == premake.CLANG then
			return iif(cfg.language == "C", "clang", "clang++")
		else
			return iif(cfg.language == "C", "gnu gcc", "gnu g++")
		end
	end

	local function project_configuration(prj, cfg)

		if not codelite.platforms.isok(cfg.platform) then return end

		local compiler = getcompilername(cfg)
		local cfgname  = codelite.getconfigname(cfg)
		local debugger = "GNU gdb debugger"

		_p(2, '<Configuration Name="%s" CompilerType="%s" DebuggerType="%s" Type="%s">',
		cfgname, compiler, debugger, codelite.types[cfg.kind])

		-- Non custom build
		configuration_buildoptions(cfg)
		configuration_linkoptions(cfg)
		configuration_resoptions(cfg)
		configuration_buildrules(cfg)

		-- Common with custom build
		configuration_targetoptions(prj, cfg)
		configuration_environment(prj, cfg)
		configuration_debugger(prj, cfg)
		configuration_prebuildcommands(prj, cfg)
		configuration_postbuildcommands(prj, cfg)
		configuration_codecompletion(prj, cfg)

		configuration_custombuild(prj, cfg)

		_p(2, '</Configuration>')
	end
--
-- Project: settings, globals and configurations
--
	local function project_settings(prj)

		_p(1, '<Settings Type="%s">', codelite.types[prj.kind])

		project_globalsettings(prj)

		for cfg in project.eachconfig(prj) do
			project_configuration(prj, cfg)
		end

		_p(1, '</Settings>')
	end

	local function project_dependencies(prj)

		local dependencies = project.getdependencies(prj)
		for cfg in project.eachconfig(prj) do
			cfgname = codelite.getconfigname(cfg)
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
--
-- Project: Generate the CodeLite project file.
--
	function codelite.project.generate(prj)

		_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<CodeLite_Project Name="%s">', prj.name)

		project_description(prj)
		project_files(prj)
		project_settings(prj)
		project_dependencies(prj)

		_p('</CodeLite_Project>')
	end
