
--
-- Create a vslinux namespace to isolate the additions
--
local p = premake

if not p.modules.vslinux then
	require ("vstudio")
	p.modules.vslinux = {}

	include("vslinux_vcxproj.lua")
end

return p.modules.vslinux
