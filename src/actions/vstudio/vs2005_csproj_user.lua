--
-- vs2005_csproj_user.lua
-- Generate a Visual Studio 2005/2008 C# .user file.
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	local p = premake
	local cs2005 = p.vstudio.cs2005
	local project = p.project


--
-- Generate a Visual Studio 200x C# user file, with support for the new platforms API.
--

	function cs2005.generateUser(prj)
		p.vstudio.projectElement()
		_p(1,'<PropertyGroup>')

		-- Per-configuration reference paths aren't supported (are they?) so just
		-- use the first configuration in the project
		local cfg = project.getfirstconfig(prj)

		local refpaths = path.translate(project.getrelative(prj, cfg.libdirs))
		_p(2,'<ReferencePath>%s</ReferencePath>', table.concat(refpaths, ";"))

		_p('  </PropertyGroup>')

		for cfg in project.eachconfig(prj) do
			local contents = p.capture(function()
				cs2005.debugsettings(cfg)
			end)

			if #contents > 0 then
				_p(1,'<PropertyGroup %s>', cs2005.condition(cfg))
				p.outln(contents)
				_p(1,'</PropertyGroup>')
			end
		end

		_p('</Project>')
	end

	function cs2005.debugsettings(cfg)
		cs2005.localDebuggerCommandArguments(cfg)
	end

	function cs2005.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			_x(2,'<StartArguments>%s</StartArguments>', table.concat(cfg.debugargs, " "))
		end
	end