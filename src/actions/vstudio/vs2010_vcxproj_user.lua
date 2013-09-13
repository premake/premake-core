--
-- vs2010_vcxproj_user.lua
-- Generate a Visual Studio 201x C/C++ project .user file
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Generate a Visual Studio 201x C++ user file, with support for the new platforms API.
--

	function vc2010.generateUser(prj)
		io.indent = "  "

		vc2010.project()
		for cfg in project.eachconfig(prj) do
			_p(1,'<PropertyGroup %s>', vc2010.condition(cfg))
			vc2010.debugsettings(cfg)
			_p(1,'</PropertyGroup>')
		end
		_p('</Project>')
	end

	function vc2010.debugsettings(cfg)
		vc2010.localDebuggerCommand(cfg)
		vc2010.localDebuggerWorkingDirectory(cfg)
		vc2010.debuggerFlavor(cfg)
		vc2010.localDebuggerCommandArguments(cfg)
		vc2010.localDebuggerEnvironment(cfg)
	end

	function vc2010.debuggerFlavor(cfg)
		if cfg.debugdir or cfg.debugcommand then
			_p(2,'<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>')
		end
	end

	function vc2010.localDebuggerCommand(cfg)
		if cfg.debugcommand then
			local dir = project.getrelative(cfg.project, cfg.debugcommand)
			_p(2,'<LocalDebuggerCommand>%s</LocalDebuggerCommand>', path.translate(dir))
		end
	end

	function vc2010.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			_x(2,'<LocalDebuggerCommandArguments>%s</LocalDebuggerCommandArguments>', table.concat(cfg.debugargs, " "))
		end
	end

	function vc2010.localDebuggerWorkingDirectory(cfg)
		if cfg.debugdir then
			local dir = project.getrelative(cfg.project, cfg.debugdir)
			_x(2,'<LocalDebuggerWorkingDirectory>%s</LocalDebuggerWorkingDirectory>', path.translate(dir))
		end
	end

	function vc2010.localDebuggerEnvironment(cfg)
		if #cfg.debugenvs > 0 then
			local envs = table.concat(cfg.debugenvs, "\n")
			if cfg.flags.DebugEnvsInherit then
				envs = envs .. "\n$(LocalDebuggerEnvironment)"
			end
			_p(2,'<LocalDebuggerEnvironment>%s</LocalDebuggerEnvironment>', envs)
			if cfg.flags.DebugEnvsDontMerge then
				_p(2,'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
			end
		end
	end
