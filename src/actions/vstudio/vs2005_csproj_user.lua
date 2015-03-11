--
-- vs2005_csproj_user.lua
-- Generate a Visual Studio 2005/2008 C# .user file.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
--

	local p = premake
	local m = p.vstudio.cs2005


--
-- Generate a Visual Studio 200x C# user file.
--

	function m.generateUser(prj)
		p.vstudio.projectElement()
		p.push('<PropertyGroup>')

		-- Per-configuration reference paths aren't supported (are they?) so just
		-- use the first configuration in the project
		local cfg = p.project.getfirstconfig(prj)

		local refpaths = path.translate(p.project.getrelative(prj, cfg.libdirs))
		p.w('<ReferencePath>%s</ReferencePath>', table.concat(refpaths, ";"))

		p.pop('</PropertyGroup>')

		for cfg in p.project.eachconfig(prj) do
			local contents = p.capture(function()
				p.push()
				m.debugsettings(cfg)
				p.pop()
			end)

			if #contents > 0 then
				p.push('<PropertyGroup %s>', m.condition(cfg))
				p.outln(contents)
				p.pop('</PropertyGroup>')
			end
		end

		p.outln('</Project>')
	end



	function m.debugsettings(cfg)
		m.localDebuggerCommandArguments(cfg)
	end

	function m.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			p.x('<StartArguments>%s</StartArguments>', table.concat(cfg.debugargs, " "))
		end
	end