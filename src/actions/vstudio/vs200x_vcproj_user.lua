--
-- vs200x_vcproj_user.lua
-- Generate a Visual Studio 2002-2008 C/C++ project .user file
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local p = premake
	local vstudio = premake.vstudio
	local project = p.project

	local m = p.vstudio.vc200x


--
-- Generate a Visual Studio 200x C++ user file, with support for the new platforms API.
--

	function m.generate_user(prj)
		p.indent("\t")
		m.xmlElement()
		p.push('<VisualStudioUserFile')
		p.w('ProjectType="Visual C++"')
		m.version()
		p.w('ShowAllFiles="false"')
		p.w('>')

		p.push('<Configurations>')
		for cfg in project.eachconfig(prj) do
			m.userconfiguration(cfg)
			m.debugdir(cfg)
			p.pop('</Configuration>')
		end
		p.pop('</Configurations>')
		p.pop('</VisualStudioUserFile>')
	end


--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	function m.userconfiguration(cfg)
		p.push('<Configuration')
		p.x('Name="%s"', vstudio.projectConfig(cfg))
		p.w('>')
	end


--
-- Write out the debug settings for this project.
--

	function m.debugdir(cfg)
		p.push('<DebugSettings')

		if cfg.debugcommand then
			local command = project.getrelative(cfg.project, cfg.debugcommand)
			p.x('Command="%s"', path.translate(command))
		end

		if cfg.debugdir then
			local debugdir = project.getrelative(cfg.project, cfg.debugdir)
			p.x('WorkingDirectory="%s"', path.translate(debugdir))
		end

		if #cfg.debugargs > 0 then
			p.x('CommandArguments="%s"', table.concat(cfg.debugargs, " "))
		end

		if #cfg.debugenvs > 0 then
			p.x('Environment="%s"', table.concat(cfg.debugenvs, "\n"))
			if cfg.flags.DebugEnvsDontMerge then
				p.x('EnvironmentMerge="false"')
			end
		end

		p.pop('/>')
	end
