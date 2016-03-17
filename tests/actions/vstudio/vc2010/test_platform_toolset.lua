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

	local wks, prj

	function suite.setup()
		premake.action.set("vs2012")
		wks, prj = test.createWorkspace()
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
		premake.action.set("vs2010")
		prepare()
		test.isemptycapture()
	end


	function suite.correctDefault_onVS2012()
		premake.action.set("vs2012")
		prepare()
		test.capture [[
<PlatformToolset>v110</PlatformToolset>
		]]
	end


	function suite.correctDefault_onVS2013()
		premake.action.set("vs2013")
		prepare()
		test.capture [[
<PlatformToolset>v120</PlatformToolset>
		]]
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

	function suite.canOverrideFromScript_withXP()
		toolset "v120_xp"
		prepare()
		test.capture [[
<PlatformToolset>v120_xp</PlatformToolset>
		]]
	end

	function suite.canOverrideFromScript_withLLVM()
		toolset "msc-llvm-vs2014_xp"
		prepare()
		test.capture [[
<PlatformToolset>LLVM-vs2014_xp</PlatformToolset>
		]]
	end

--
-- Check if platform toolset element is being emitted correctly.
--

	function suite.output_onConsoleAppAndNoCpp()
		kind "ConsoleApp"
		removefiles "hello.cpp"
		prepare()
		test.capture [[
<PlatformToolset>v110</PlatformToolset>
		]]
	end

	function suite.skipped_onNoMakefileAndNoCpp()
		kind "Makefile"
		removefiles "hello.cpp"
		prepare()
		test.isemptycapture()
	end

	function suite.output_onNoMakefileAndCpp()
		kind "Makefile"
		prepare()
		test.capture [[
<PlatformToolset>v110</PlatformToolset>
		]]
	end
