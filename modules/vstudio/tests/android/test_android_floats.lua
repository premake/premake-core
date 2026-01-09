--
-- test_android_floats.lua
-- Test Android float settings
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("test_android_floats")
local vc2010 = p.vstudio.vc2010

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2013")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		system "android"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.androidAdditionalCompileOptions(cfg)
		vc2010.gccClangAdditionalCompileOptions(cfg)
	end


--
-- Test software floating point ABI on ARM
--


	function suite.softFloatingPoint_ARM()
		floatabi "Soft"
		architecture "ARM"
		prepare()
		test.capture [[
<AdditionalOptions>-mfloat-abi=soft %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test softfp floating point ABI on ARM
--


	function suite.softfpFloatingPoint_ARM()
		floatabi "SoftFP"
		architecture "ARM"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=vfp -mfloat-abi=softfp %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test hard floating point ABI on ARM
--


	function suite.hardFloatingPoint_ARM()
		floatabi "Hard"
		architecture "ARM"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=vfp -mfloat-abi=hard %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test software floating point ABI on ARMv7
--


	function suite.softFloatingPoint_ARMv7()
		floatabi "Soft"
		architecture "ARMv7"
		prepare()
		test.capture [[
<AdditionalOptions>-mfloat-abi=soft %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test softfp floating point ABI on ARMv7
--


	function suite.softfpFloatingPoint_ARMv7()
		floatabi "SoftFP"
		architecture "ARMv7"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=vfpv3-d16 -mfloat-abi=softfp %(AdditionalOptions)</AdditionalOptions>
		]]

	end


--
-- Test hard floating point ABI on ARMv7
--


	function suite.hardFloatingPoint_ARMv7()
		floatabi "Hard"
		architecture "ARMv7"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=vfpv3-d16 -mfloat-abi=hard %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test soft floating point ABI on ARMv7 with Neon vector extensions
--


	function suite.softFloatingPoint_ARMv7_Neon()
		floatabi "Soft"
		architecture "ARMv7"
		vectorextensions "Neon"
		prepare()
		test.capture [[
<AdditionalOptions>-mfloat-abi=soft %(AdditionalOptions)</AdditionalOptions>
		]]
	end
	

--
-- Test softfp floating point ABI on ARMv7 with Neon vector extensions
--

	function suite.softfpFloatingPoint_ARMv7_Neon()
		floatabi "SoftFP"
		architecture "ARMv7"
		vectorextensions "Neon"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=neon -mfloat-abi=softfp %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test hard floating point ABI on ARMv7 with Neon vector extensions
--

	function suite.hardFloatingPoint_ARMv7_Neon()
		floatabi "Hard"
		architecture "ARMv7"
		vectorextensions "Neon"
		prepare()
		test.capture [[
<AdditionalOptions>-mfpu=neon -mfloat-abi=hard %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- Test MIPS architecture with MXU vector extensions
--


function suite.mips_Mxu()
		floatabi "Soft"
		architecture "MIPS"
		vectorextensions "MXU"
		prepare()
		test.capture [[
<AdditionalOptions>-mmxu %(AdditionalOptions)</AdditionalOptions>
		]]
	end
