--
-- tests/actions/vstudio/vc200x/test_resource_compiler.lua
-- Validate generation the VCResourceCompilerTool element in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vs200x_resource_compiler = { }
	local suite = T.vs200x_resource_compiler
	local vc200x = premake.vstudio.vc200x


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2008"
		sln, prj = test.createsolution()
	end

	local function prepare()
		cfg = premake5.project.getconfig(prj, "Debug")
		vc200x.VCResourceCompilerTool_ng(cfg)
	end


--
-- Verify the basic structure of the compiler block with no flags or settings.
--

	function suite.looksGood_onDefaultSettings()
		prepare()
		test.capture [[
			<Tool
				Name="VCResourceCompilerTool"
			/>
		]]
	end


--
-- Both includedirs and resincludedirs should be used.
--

	function suite.usesBothIncludeAndResIncludeDirs()
		includedirs { "../include" }
		resincludedirs { "../res/include" }
		prepare()
		test.capture [[
			<Tool
				Name="VCResourceCompilerTool"
				AdditionalIncludeDirectories="..\include;..\res\include"
			/>
		]]
	end
