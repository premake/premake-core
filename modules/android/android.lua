
--
-- Create an android namespace to isolate the additions
--
local p = premake

if not p.modules.android then
	require ("vstudio")
	p.modules.android = {}

	if _ACTION < "vs2015" then
		configuration { "Android" }
			system "android"
			toolset "gcc"
	end

	-- TODO: configure Android debug environment...

	include("vsandroid_vcxproj.lua")
	include("vsandroid_sln2005.lua")
	include("vsandroid_vstudio.lua")
	include("vsandroid_androidproj.lua")
end

return p.modules.android
