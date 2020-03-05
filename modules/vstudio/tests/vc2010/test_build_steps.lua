--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2020 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_build_steps")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.buildStep(cfg)
	end

--
-- Check that we output nothing unless there is something to output
--

	function suite.buildStepNone()
		prepare()
		test.capture [[
		]]
	end

--
-- Check the basic build step example
--

	function suite.buildStepBasic()
		buildcommands("Example.exe")
		prepare()
		test.capture [[
<CustomBuildStep>
	<Command>Example.exe</Command>
</CustomBuildStep>
		]]
	end
	
--
-- Check a normal build step setup
--

	function suite.buildStepCommon()
		buildcommands("Example.exe")
		buildoutputs("Example.out")
		buildinputs("Example.in")
		buildmessage("Hello World")
		prepare()
		test.capture [[
<CustomBuildStep>
	<Command>Example.exe</Command>
	<Message>Hello World</Message>
	<Outputs>Example.out</Outputs>
	<Inputs>Example.in</Inputs>
</CustomBuildStep>
		]]
	end
	
	
--
-- Check a more complex build step setup
--

	function suite.buildStepComplex()
		buildcommands ( "Example.exe" )
		buildoutputs { "Example.out", "Example2.out" }
		buildinputs { "Example.in", "Example2.in" }
		buildmessage("Hello World")
		prepare()
		test.capture [[
<CustomBuildStep>
	<Command>Example.exe</Command>
	<Message>Hello World</Message>
	<Outputs>Example.out;Example2.out</Outputs>
	<Inputs>Example.in;Example2.in</Inputs>
</CustomBuildStep>
		]]
	end