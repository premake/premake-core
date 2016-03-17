--
-- tests/actions/vstudio/vc2010/test_manifest.lua
-- Validate generation of Manifest block in Visual Studio 201x C/C++ projects.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_manifest")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		wks, prj = test.createWorkspace()
		kind "ConsoleApp"
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.manifest(cfg)
	end


--
-- Check the basic element structure with default settings.
--

	function suite.defaultSettings()
		files { "source/test.manifest" }
		prepare()
		test.capture [[
<Manifest>
	<AdditionalManifestFiles>source/test.manifest %(AdditionalManifestFiles)</AdditionalManifestFiles>
</Manifest>
		]]
	end

--
-- Check that there is no manifest when using static lib
--

	function suite.staticLib()
		kind "StaticLib"
		files { "test.manifest" }
		prepare()
		test.isemptycapture()
	end
