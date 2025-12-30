--
-- tests/tools/test_incrementallink.lua
-- Test incrementallink API and its integration with tools and exporters
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("test_incrementallink")
	local p = premake
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
-- Test incrementallink API with msc tool
--

	function suite.incrementallinkOff_msc()
		incrementallink "Off"
		prepare()
		test.contains("/INCREMENTAL:NO", msc.getldflags(cfg))
	end

	function suite.incrementallinkOn_msc()
		incrementallink "On"
		prepare()
		test.excludes("/INCREMENTAL:NO", msc.getldflags(cfg))
	end

	function suite.incrementallinkDefault_msc()
		incrementallink "Default"
		prepare()
		test.excludes("/INCREMENTAL:NO", msc.getldflags(cfg))
	end


--
-- Test config.canLinkIncremental
--

	function suite.canLinkIncremental_default()
		prepare()
		test.istrue(p.config.canLinkIncremental(cfg))
	end

	function suite.canLinkIncremental_off()
		incrementallink "Off"
		prepare()
		test.isfalse(p.config.canLinkIncremental(cfg))
	end

	function suite.canLinkIncremental_on()
		incrementallink "On"
		prepare()
		test.istrue(p.config.canLinkIncremental(cfg))
	end

	function suite.canLinkIncremental_onWithOptimize()
		incrementallink "On"
		optimize "On"
		prepare()
		-- Explicit "On" should override optimization
		test.istrue(p.config.canLinkIncremental(cfg))
	end

	function suite.canLinkIncremental_defaultWithOptimize()
		incrementallink "Default"
		optimize "On"
		prepare()
		-- Default should respect optimization
		test.isfalse(p.config.canLinkIncremental(cfg))
	end


--
-- Test deprecated flag still works
--

	function suite.deprecatedFlag_NoIncrementalLink()
		flags "NoIncrementalLink"
		prepare()
		test.contains("/INCREMENTAL:NO", msc.getldflags(cfg))
	end

	function suite.deprecatedFlag_canLinkIncremental()
		flags "NoIncrementalLink"
		prepare()
		test.isfalse(p.config.canLinkIncremental(cfg))
	end
