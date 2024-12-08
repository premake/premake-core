--
-- android/vsandroid_vstudio.lua
-- vs-android integration for vstudio.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	--local p = premake
	--
	--local android = p.modules.android
	--local vsandroid = p.modules.vsandroid
	--local vstudio = p.vstudio

--
-- Add android tools to vstudio actions.
--


	--[[premake.override(vstudio, "solutionPlatform", function (oldfn, cfg)
		local platform = oldfn(cfg)

		-- Bypass that pesky Win32 hack
		if cfg.system == premake.ANDROID and _ACTION >= "vs2015" then
			if cfg.platform == "x86" then
				platform = "x86"
			end
		end

		return platform
	end)


	premake.override(vstudio, "archFromConfig", function (oldfn, cfg, win32)
		-- Bypass that pesky Win32 hack by not passing win32 down
		if cfg.system == premake.ANDROID and _ACTION >= "vs2015" then
			return oldfn(cfg)
		end
		return oldfn(cfg, win32)
	end)
