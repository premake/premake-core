
--
-- Create an android namespace to isolate the additions
--
	premake.modules.android = {}

	local android = premake.modules.android

	include("_preload.lua")

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

	return android
