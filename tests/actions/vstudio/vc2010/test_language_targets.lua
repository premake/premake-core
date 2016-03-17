--
-- tests/actions/vstudio/vc2010/test_language_targets.lua
-- Check the import language targets block of a VS 2010 project.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_language_targets")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2010")
		rule "MyRules"
		rule "MyOtherRules"
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = test.getproject(wks)
		vc2010.importLanguageTargets(prj)
	end


--
-- Writes language targets.
--

	function suite.structureIsCorrect()
		prepare()
		test.capture [[
<Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
		]]
	end
