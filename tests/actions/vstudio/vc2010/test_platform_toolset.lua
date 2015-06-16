--
-- tests/actions/vstudio/vc2010/test_platform_toolset.lua
-- Validate VC platform toolset generation.
-- Copyright (c) 2013-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_platform_toolset")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2012"
		sln, prj = test.createsolution()
		files "hello.cpp"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
		vc2010.platformToolset(cfg)
	end



--
-- Check default values for each version.
--

	function suite.correctDefault_onVS2010()
		_ACTION = "vs2010"
		prepare()
		test.isemptycapture()
	end


	function suite.correctDefault_onVS2012()
		_ACTION = "vs2012"
		prepare()
		test.capture [[
<PlatformToolset>v110</PlatformToolset>
		]]
	end


	function suite.correctDefault_onVS2013()
		_ACTION = "vs2013"
		prepare()
		test.capture [[
<PlatformToolset>v120</PlatformToolset>
		]]
	end


--
-- Element should only be written if C++ files are present.
--

	function suite.empty_onNoRelevantSources()
		removefiles "hello.cpp"
		prepare()
		test.isemptycapture()
	end


--
-- Check for overrides from project scripts.
--

	function suite.canOverrideFromScript_withV()
		toolset "v90"
		prepare()
		test.capture [[
<PlatformToolset>v90</PlatformToolset>
		]]
	end

	function suite.canOverrideFromScript_withMsc()
		toolset "msc-100"
		prepare()
		test.capture [[
<PlatformToolset>v100</PlatformToolset>
		]]
	end
