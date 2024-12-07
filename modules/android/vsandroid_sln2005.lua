--
-- android/vsandroid_sln2005.lua
-- vs-android integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	--local p = premake
	--
	--local android = p.modules.android
	--local vsandroid = p.modules.vsandroid
	--local sln2005 = p.vstudio.sln2005


--
-- Add android tools to vstudio actions.
--


	--[[premake.override(sln2005.elements, "projectConfigurationPlatforms", function(oldfn, cfg, context)
		local elements = oldfn(cfg, context)

		if cfg.system == premake.ANDROID and _ACTION >= "vs2015" then
			elements = table.join(elements, {
				android.deployProject
			})
		end

		return elements
	end)


	function android.deployProject(cfg, context)
		if context.prjCfg.kind == p.PACKAGING and _ACTION >= "vs2015" then
			p.w('{%s}.%s.Deploy.0 = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
		end
	end]]--
