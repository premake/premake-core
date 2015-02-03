--
-- vs2010_vcxproj_user.lua
-- Generate a Visual Studio 201x C/C++ project .user file
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local p = premake
	local vstudio = p.vstudio
	local vc2010 = p.vstudio.vc2010
	local project = p.project

	local m = p.vstudio.vc2010


--
-- Generate a Visual Studio 201x C++ user file, with support for the new platforms API.
--

	function m.generateUser(prj)
		m.xmlDeclaration()
		m.userProject()
		for cfg in project.eachconfig(prj) do
			p.push('<PropertyGroup %s>', m.condition(cfg))
			m.debugSettings(cfg)
			p.pop('</PropertyGroup>')
		end
		_p('</Project>')
	end



--
-- Output the XML declaration and opening <Project> tag.
--

	function m.userProject()
		local action = premake.action.current()
		p.push('<Project ToolsVersion="%s" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">',
			action.vstudio.toolsVersion)
	end



	vc2010.elements.debugSettings = function(cfg)
		return {
			vc2010.localDebuggerCommand,
			vc2010.localDebuggerWorkingDirectory,
			vc2010.debuggerFlavor,
			vc2010.localDebuggerCommandArguments,
			vc2010.localDebuggerEnvironment,
			vc2010.localDebuggerMergeEnvironment,
		}
	end

	function vc2010.debugSettings(cfg)
		p.callArray(vc2010.elements.debugSettings, cfg)
	end



	function vc2010.debuggerFlavor(cfg)
		if cfg.debugdir or cfg.debugcommand then
			p.w('<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>')
		end
	end



	function vc2010.localDebuggerCommand(cfg)
		if cfg.debugcommand then
			local dir = project.getrelative(cfg.project, cfg.debugcommand)
			p.w('<LocalDebuggerCommand>%s</LocalDebuggerCommand>', path.translate(dir))
		end
	end



	function vc2010.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			p.x('<LocalDebuggerCommandArguments>%s</LocalDebuggerCommandArguments>', table.concat(cfg.debugargs, " "))
		end
	end



	function vc2010.localDebuggerWorkingDirectory(cfg)
		if cfg.debugdir then
			local dir = project.getrelative(cfg.project, cfg.debugdir)
			p.x('<LocalDebuggerWorkingDirectory>%s</LocalDebuggerWorkingDirectory>', path.translate(dir))
		end
	end



	function vc2010.localDebuggerEnvironment(cfg)
		if #cfg.debugenvs > 0 then
			local envs = table.concat(cfg.debugenvs, "\n")
			if cfg.flags.DebugEnvsInherit then
				envs = envs .. "\n$(LocalDebuggerEnvironment)"
			end
			p.w('<LocalDebuggerEnvironment>%s</LocalDebuggerEnvironment>', envs)

			if cfg.flags.DebugEnvsDontMerge then
				p.w(2,'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
			end
		end
	end



	function vc2010.localDebuggerMergeEnvironment(cfg)
		if #cfg.debugenvs > 0 and cfg.flags.DebugEnvsDontMerge then
			p.w(2,'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
		end
	end
