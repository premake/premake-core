--
-- tests/actions/vstudio/vc200x/test_resource_compiler.lua
-- Validate generation the VCResourceCompilerTool element in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs200x_resource_compiler")
	local vc200x = p.vstudio.vc200x


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCResourceCompilerTool(cfg)
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


--
-- Test locale conversion to culture codes.
--

	function suite.culture_en_NZ()
		locale "en-NZ"
		prepare()
		test.capture [[
<Tool
	Name="VCResourceCompilerTool"
	Culture="5129"
/>
		]]
	end
