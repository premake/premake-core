--
-- vs200x_vcproj_user.lua
-- Generate a Visual Studio 2002-2008 C/C++ project .user file
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local vc200x = premake.vstudio.vc200x
	local project = premake5.project


--
-- Generate a Visual Studio 200x C++ user file, with support for the new platforms API.
--

	function vc200x.generate_user_ng(prj)
		io.eol = "\r\n"

		vc200x.xmldeclaration()
		_p('<VisualStudioUserFile')
		_p(1,'ProjectType="Visual C++"')
		vc200x.projectversion()
		_p(1,'ShowAllFiles="false"')
		_p(1,'>')

		_p(1,'<Configurations>')
		for cfg in project.eachconfig(prj) do
			vc200x.userconfiguration(cfg)
			vc200x.debugdir_ng(cfg)
			_p(2,'</Configuration>')
		end
		_p(1,'</Configurations>')

		_p('</VisualStudioUserFile>')
	end


--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	function vc200x.userconfiguration(cfg)
		_p(2,'<Configuration')
		_x(3,'Name="%s"', vstudio.configname(cfg))
		_p(3,'>')
	end


--
-- Write out the debug settings for this project.
--

	function vc200x.debugdir_ng(cfg)
		_p(3,'<DebugSettings')
		
		if cfg.debugdir then
			local debugdir = project.getrelative(cfg.project, cfg.debugdir)
			_x(4,'WorkingDirectory="%s"', path.translate(debugdir))
		end
		
		if #cfg.debugargs > 0 then
			_x(4,'CommandArguments="%s"', table.concat(cfg.debugargs, " "))
		end

		if #cfg.debugenvs > 0 then
			_p(4,'Environment="%s"', table.concat(premake.esc(cfg.debugenvs), "&#x0A;"))
			if cfg.flags.DebugEnvsDontMerge then
				_p(4,'EnvironmentMerge="false"')
			end
		end

		_p(3,'/>')
	end



-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

--
-- Generate the .vcproj.user file
--

	function vc200x.generate_user(prj)
		vc200x.header('VisualStudioUserFile')
		
		_p(1,'ShowAllFiles="false"')
		_p(1,'>')
		_p(1,'<Configurations>')
		
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			if cfginfo.isreal then
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
		
				_p(2,'<Configuration')
				_p(3,'Name="%s"', premake.esc(cfginfo.name))
				_p(3,'>')
				
				vc200x.debugdir(cfg)
				
				_p(2,'</Configuration>')
			end
		end		
		
		_p(1,'</Configurations>')
		_p('</VisualStudioUserFile>')
	end


--
-- Output the debug settings element
--
	function vc200x.environmentargs(cfg)
		if cfg.environmentargs and #cfg.environmentargs > 0 then
			_p(4,'Environment="%s"', string.gsub(table.concat(cfg.environmentargs, "&#x0A;"),'"','&quot;'))
			if cfg.flags.EnvironmentArgsDontMerge then
				_p(4,'EnvironmentMerge="false"')
			end
		end
	end
	
	function vc200x.debugdir(cfg)
		_p(3,'<DebugSettings')
		
		if cfg.debugdir then
			_p(4,'WorkingDirectory="%s"', path.translate(cfg.debugdir, '\\'))
		end
		
		if #cfg.debugargs > 0 then
			_p(4,'CommandArguments="%s"', table.concat(cfg.debugargs, " "))
		end

			vc200x.environmentargs(cfg)
				
		_p(3,'/>')
	end
