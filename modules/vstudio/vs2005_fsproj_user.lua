--
-- vs2005_fsproj_user.lua
-- Generate a Visual Studio 2005+ F# .user file.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local m = p.vstudio.fs2005
	local dn = p.vstudio.dotnetbase


--
-- Generate a Visual Studio 200x C# user file.
--

	m.elements.userProjectPropertyGroup = function()
		return {
			m.referencePath,
		}
	end

	m.elements.userConfigPropertyGroup = function()
		return {
			m.localDebuggerCommandArguments,
		}
	end

	function m.generateUser(prj)
		-- Only want output if there is something to configure
		local prjGroup = p.capture(function()
			p.push(2)
			p.callArray(m.elements.userProjectPropertyGroup, prj)
			p.pop(2)
		end)

		local contents = {}
		local size = 0

		for cfg in p.project.eachconfig(prj) do
			contents[cfg] = p.capture(function()
				p.push(2)
				p.callArray(m.elements.userConfigPropertyGroup, cfg)
				p.pop(2)
			end)
			size = size + #contents[cfg]
		end

		if #prjGroup > 0 or size > 0 then
			p.vstudio.projectElement()

			if #prjGroup > 0 then
				p.push('<PropertyGroup>')
				p.outln(prjGroup)
				p.pop('</PropertyGroup>')
			end

			for cfg in p.project.eachconfig(prj) do
				if #contents[cfg] > 0 then
					p.push('<PropertyGroup %s>', dn.condition(cfg))
					p.outln(contents[cfg])
					p.pop('</PropertyGroup>')
				end
			end

			p.pop('</Project>')
		end
	end



---
-- Output any reference paths required by the project.
---

	function m.referencePath(prj)
		-- Per-configuration reference paths aren't supported (are they?) so just
		-- use the first configuration in the project
		local cfg = p.project.getfirstconfig(prj)
		local paths = p.vstudio.path(prj, cfg.libdirs)
		if #paths > 0 then
			p.w('<ReferencePath>%s</ReferencePath>', table.concat(paths, ";"))
		end
	end



	function m.localDebuggerCommandArguments(cfg)
		if #cfg.debugargs > 0 then
			p.x('<StartArguments>%s</StartArguments>', table.concat(cfg.debugargs, " "))
		end
	end
