--
-- vs2010_vcxproj_user.lua
-- Generate a Visual Studio 201x C/C++ project .user file
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local m = p.vstudio.vc2010


--
-- Generate a Visual Studio 201x C++ user file.
--

	m.elements.user = function(cfg)
		return {
			m.debugSettings,
		}
	end

	function m.generateUser(prj)
		-- Only want output if there is something to configure
		local contents = {}
		local size = 0

		for cfg in p.project.eachconfig(prj) do
			contents[cfg] = p.capture(function()
				p.push(2)
				p.callArray(m.elements.user, cfg)
				p.pop(2)
			end)
			size = size + #contents[cfg]
		end

		if size > 0 then
			m.xmlDeclaration()
			m.userProject()
			for cfg in p.project.eachconfig(prj) do
				p.push('<PropertyGroup %s>', m.condition(cfg))
				if #contents[cfg] > 0 then
					p.outln(contents[cfg])
				end
				p.pop('</PropertyGroup>')
			end
			p.pop('</Project>')
		end
	end



--
-- Output the opening <Project> tag.
--

	function m.userProject()
		local action = p.action.current()
		p.push('<Project ToolsVersion="%s" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">',
				action.vstudio.userToolsVersion or action.vstudio.toolsVersion)
	end



	m.elements.debugSettings = function(cfg)
		return {
			m.localDebuggerCommand,
			m.localDebuggerWorkingDirectory,
			m.debuggerFlavor,
			m.localDebuggerCommandArguments,
			m.localDebuggerDebuggerType,
			m.localDebuggerEnvironment,
			m.localDebuggerMergeEnvironment,
		}
	end

	function m.debugSettings(cfg)
		p.callArray(m.elements.debugSettings, cfg)
	end



	function m.debuggerFlavor(cfg)
		local map = {
			Local = "WindowsLocalDebugger",
			Remote = "WindowsRemoteDebugger",
			WebBrowser = "WebBrowserDebugger",
			WebService = "WebServiceDebugger"
		}

		local value = map[cfg.debuggerflavor]
		if value then
			p.w('<DebuggerFlavor>%s</DebuggerFlavor>', value)
		elseif cfg.debugdir or cfg.debugcommand then
			p.w('<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>')
		end
	end



	function m.localDebuggerCommand(cfg)
		if cfg.debugcommand then
			local dir = path.translate(cfg.debugcommand)
			p.w('<LocalDebuggerCommand>%s</LocalDebuggerCommand>', dir)
		end
	end


	function m.localDebuggerDebuggerType(cfg)
		if cfg.debuggertype then
			p.w('<LocalDebuggerDebuggerType>%s</LocalDebuggerDebuggerType>', cfg.debuggertype)
		end
	end


	function m.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			local args = os.translateCommandsAndPaths(cfg.debugargs, cfg.project.basedir, cfg.project.location)
			p.x('<LocalDebuggerCommandArguments>%s</LocalDebuggerCommandArguments>', table.concat(args, " "))
		end
	end



	function m.localDebuggerWorkingDirectory(cfg)
		if cfg.debugdir then
			local dir = p.vstudio.path(cfg, cfg.debugdir)
			p.x('<LocalDebuggerWorkingDirectory>%s</LocalDebuggerWorkingDirectory>', dir)
		end
	end



	function m.localDebuggerEnvironment(cfg)
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



	function m.localDebuggerMergeEnvironment(cfg)
		if #cfg.debugenvs > 0 and cfg.flags.DebugEnvsDontMerge then
			p.w(2,'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
		end
	end
