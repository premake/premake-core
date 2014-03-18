--
-- tests/actions/vs2012/test_vcxproj_clcompile.lua
-- Validate compiler settings in Visual Studio 2012 C/C++ projects.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2012_vcxproj_clcompile")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2012"
		sln, prj = test.createsolution()
	end


--
-- Verify the new instruction sets.
--

	function suite.enhancedInstructionSet_onAVX()
		vectorextensions "avx"
		vc2010.enableEnhancedInstructionSet(test.getconfig(prj, "Debug"))
		test.capture [[
			<EnableEnhancedInstructionSet>AdvancedVectorExtensions</EnableEnhancedInstructionSet>
		]]
	end
