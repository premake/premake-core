--
-- tests/actions/vstudio/vc2010/test_extension_targets.lua
-- Check the import extension targets block of a VS 2010 project.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_extension_targets")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local wks

	function suite.setup()
		rule "MyRules"
		rule "MyOtherRules"
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = test.getproject(wks)
		vc2010.importExtensionTargets(prj)
	end


--
-- Writes an empty element when no custom rules are specified.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
</ImportGroup>
		]]
	end



--
-- Writes entries for each project scoped custom rules path.
--

	function suite.addsImport_onEachRulesFile()
		rules { "MyRules", "MyOtherRules" }
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
	<Import Project="MyRules.targets" />
	<Import Project="MyOtherRules.targets" />
</ImportGroup>
		]]
	end


--
-- Rule files use a project relative path.
--

	function suite.usesProjectRelativePaths()
		rules { "MyRules" }
		location "build"
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
	<Import Project="..\MyRules.targets" />
</ImportGroup>
		]]
	end
