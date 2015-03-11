--
-- vs200x_vcproj_user.lua
-- Generate a Visual Studio 2002-2008 C/C++ project .user file
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
--

	local p = premake
	local m = p.vstudio.vc200x



--
-- Generate a Visual Studio 200x C++ user file, with support for the new platforms API.
--

	m.elements.user = function(cfg)
		return {
			m.debugSettings,
		}
	end

	function m.generateUser(prj)
		p.indent("\t")
		m.xmlElement()
		m.visualStudioUserFile()

		p.push('<Configurations>')
		for cfg in p.project.eachconfig(prj) do
			m.userConfiguration(cfg)
			p.callArray(m.elements.user, cfg)
			p.pop('</Configuration>')
		end
		p.pop('</Configurations>')

		p.pop('</VisualStudioUserFile>')
	end



---
-- Output the opening project tag.
---

	function m.visualStudioUserFile()
		p.push('<VisualStudioUserFile')
		p.w('ProjectType="Visual C++"')
		m.version()
		p.w('ShowAllFiles="false"')
		p.w('>')
	end



--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	function m.userConfiguration(cfg)
		p.push('<Configuration')
		p.x('Name="%s"', p.vstudio.projectConfig(cfg))
		p.w('>')
	end



--
-- Write out the debug settings for this project.
--

	m.elements.debugSettings = function(cfg)
		return {
			m.debugCommand,
			m.debugDir,
			m.debugArgs,
			m.debugEnvironment,
		}
	end

	function m.debugSettings(cfg)
		p.push('<DebugSettings')
		p.callArray(m.elements.debugSettings, cfg)
		p.pop('/>')
	end


	function m.debugArgs(cfg)
		if #cfg.debugargs > 0 then
			p.x('CommandArguments="%s"', table.concat(cfg.debugargs, " "))
		end
	end


	function m.debugCommand(cfg)
		if cfg.debugcommand then
			local command = p.project.getrelative(cfg.project, cfg.debugcommand)
			p.x('Command="%s"', path.translate(command))
		end
	end


	function m.debugDir(cfg)
		if cfg.debugdir then
			local debugdir = p.project.getrelative(cfg.project, cfg.debugdir)
			p.x('WorkingDirectory="%s"', path.translate(debugdir))
		end
	end


	function m.debugEnvironment(cfg)
		if #cfg.debugenvs > 0 then
			p.x('Environment="%s"', table.concat(cfg.debugenvs, "\n"))
			if cfg.flags.DebugEnvsDontMerge then
				p.x('EnvironmentMerge="false"')
			end
		end
	end
