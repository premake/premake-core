--
-- tests/actions/vstudio/vc2010/test_manifest.lua
-- Validate generation of Manifest block in Visual Studio 201x C/C++ projects.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_manifest")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
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
	<AdditionalManifestFiles>source/test.manifest;%(AdditionalManifestFiles)</AdditionalManifestFiles>
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

--
-- Check that DPI Awareness emits correctly
--

	function suite.dpiAwareness_None()
		dpiawareness "None"
		prepare()
		test.capture [[
<Manifest>
	<EnableDpiAwareness>false</EnableDpiAwareness>
</Manifest>
		]]
	end

	function suite.dpiAwareness_High()
		dpiawareness "High"
		prepare()
		test.capture [[
<Manifest>
	<EnableDpiAwareness>true</EnableDpiAwareness>
</Manifest>
		]]
	end

	function suite.dpiAwareness_HighPerMonitor()
		dpiawareness "HighPerMonitor"
		prepare()
		test.capture [[
<Manifest>
	<EnableDpiAwareness>PerMonitorHighDPIAware</EnableDpiAwareness>
</Manifest>
		]]
	end
