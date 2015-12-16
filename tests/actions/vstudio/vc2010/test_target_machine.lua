---
-- tests/actions/vstudio/vc2010/test_target_machine.lua
-- Validate generation of the <TargetMachine> element
-- Copyright (c) 2015 Jason Perkins and the Premake project
---

	local suite = test.declare("vstudio_vs2010_target_machine")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.targetMachine(cfg)
	end



--
-- Emit if a static lib project contains a resource file and an
-- architecture is specified.
--

	function suite.emitsOnStaticLibWithX86()
		kind "StaticLib"
		architecture "x86"
		prepare()
		test.capture [[
<TargetMachine>MachineX86</TargetMachine>
		]]
	end

	function suite.emitsOnStaticLibWithX86_64()
		kind "StaticLib"
		architecture "x86_64"
		prepare()
		test.capture [[
<TargetMachine>MachineX64</TargetMachine>
		]]
	end



--
-- Other combinations should NOT emit anything
--

	function suite.isIgnoredOnConsoleAppNoArch()
		kind "ConsoleApp"
		prepare()
		test.isemptycapture()
	end

	function suite.isIgnoredOnConsoleAppWithX86()
		kind "ConsoleApp"
		architecture "x86"
		prepare()
		test.isemptycapture()
	end

	function suite.isIgnoredOnStaticLibNoArch()
		kind "StaticLib"
		prepare()
		test.isemptycapture()
	end

	function suite.isIgnoredOnSharedLibNoArch()
		kind "SharedLib"
		prepare()
		test.isemptycapture()
	end

	function suite.isIgnoredOnSharedLibWithX86()
		kind "SharedLib"
		architecture "x86"
		prepare()
		test.isemptycapture()
	end
