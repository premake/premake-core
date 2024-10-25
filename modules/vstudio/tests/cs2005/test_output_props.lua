--
-- tests/actions/vstudio/cs2005/test_output_props.lua
-- Test the target output settings of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_output_props")
	local dn2005 = p.vstudio.dotnetbase
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks, prj = test.createWorkspace()
		language "C#"
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.outputProps(cfg)
	end


--
-- Check handling of the output directory.
--

	function suite.outputDirectory_onTargetDir()
		targetdir "../build"
		prepare()
		test.capture [[
		<OutputPath>..\build\</OutputPath>
		]]
	end


--
-- Check handling of the intermediates directory.
--

	function suite.intermediateDirectory_onVs2008()
		p.action.set("vs2008")
		prepare()
		test.capture [[
		<OutputPath>bin\Debug\</OutputPath>
		<IntermediateOutputPath>obj\Debug\</IntermediateOutputPath>
		]]
	end

	function suite.intermediateDirectory_onVs2010()
		p.action.set("vs2010")
		prepare()
		test.capture [[
		<OutputPath>bin\Debug\</OutputPath>
		<BaseIntermediateOutputPath>obj\Debug\</BaseIntermediateOutputPath>
		<IntermediateOutputPath>$(BaseIntermediateOutputPath)</IntermediateOutputPath>
		]]
	end

