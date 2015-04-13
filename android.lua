
--
-- Create an android namespace to isolate the additions
--
	premake.modules.android = {}

	local android = premake.modules.android

	include("_preload.lua")

	configuration { "Android" }
		system "android"
		toolset "gcc"

	-- TODO: configure Android debug environment...

	include("vsandroid_vcxproj.lua")

	return android
