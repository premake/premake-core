--
-- tests/tools/test_manifest.lua
-- Test manifest API and its integration with tools and exporters
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("test_manifest")
	local msc = p.tools.msc

--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Test manifest API with MSC toolset.
--

	function suite.manifestDefault_msc()
		manifest "Default"
		prepare()
		test.excludes("/MANIFEST:NO", msc.getldflags(cfg))
	end

	function suite.manifestOff_msc()
		manifest "Off"
		prepare()
		test.contains("/MANIFEST:NO", msc.getldflags(cfg))
	end

	function suite.manifestOn_msc()
		manifest "On"
		prepare()
		test.excludes("/MANIFEST:NO", msc.getldflags(cfg))
	end


--
-- Test deprecated NoManifest flag compatibility.
--

	function suite.deprecatedFlag_NoManifest()
		flags "NoManifest"
		prepare()
		test.contains("/MANIFEST:NO", msc.getldflags(cfg))
	end
