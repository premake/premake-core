--
-- vs2019_vcxproj_user.lua
-- Generate a Visual Studio 2010 C/C++ project .user file
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Generate a Visual Studio 2010 C++ user file, with support for the new platforms API.
--

	function vc2010.generate_user_ng(prj)
		io.eol = "\r\n"
		io.indent = "  "
		
		vc2010.header_ng()
		for cfg in project.eachconfig(prj) do
			_p(1,'<PropertyGroup %s>', vc2010.condition(cfg))
			vc2010.debugsettings(cfg)
			_p(1,'</PropertyGroup>')
		end
		_p('</Project>')
	end

	function vc2010.debugsettings(cfg)
		if cfg.debugdir then
			local dir = project.getrelative(cfg.project, cfg.debugdir)
			_x(2,'<LocalDebuggerWorkingDirectory>%s</LocalDebuggerWorkingDirectory>', path.translate(dir))
			_p(2,'<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>')	
		end
		if #cfg.debugargs > 0 then
			_x(2,'<LocalDebuggerCommandArguments>%s</LocalDebuggerCommandArguments>', table.concat(cfg.debugargs, " "))
		end
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
