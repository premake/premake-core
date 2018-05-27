
--
-- Create an Xbox 360 namespace to isolate the additions
--
local p = premake

if not p.modules.xbox360 then
	require ("vstudio")
	p.modules.xbox360 = {}

	if _ACTION < "vs2015" then
		configuration { "xbox360" }
			system "xbox360"
	end

	include("xbox360_vcxproj.lua")
	include("xbox360_sln2005.lua")
	include("xbox360_vstudio.lua")
end

return p.modules.xbox360
