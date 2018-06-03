--
-- xbox360/xbox360_vstudio.lua
-- Xbox 360 integration for vstudio.
-- Author: Emilio López
-- Copyright (c) 2018-2018 Jason Perkin and the Premake project
--

	local p = premake

	local xbox360 = p.modules.xbox360
	local vstudio = p.vstudio

--
-- Add Xbox 360 to vstudio actions.
--

	premake.override(vstudio, "archFromConfig", function (oldfn, cfg, win32)
		-- Bypass that pesky Win32 hack by not passing win32 down
		if cfg.system == premake.Xbox360 and _ACTION >= "vs2015" then
			
			local archMap = {
				["xbox360"] = "Xbox360",
				["Xbox360"] = "Xbox360",
			}
			
			if cfg.architecture ~= nil and archMap[cfg.architecture] ~= nil then
				return archMap[cfg.architecture]
			else			
				return oldfn(cfg)
			end			
		end
		
		return oldfn(cfg, win32)
	end)
