
--
-- Create an android namespace to isolate the additions
--
	premake.modules.android = {}

	local android = premake.modules.android

	include("_preload.lua")
	include("vsandroid_vcxproj.lua")

	return android
