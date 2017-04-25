--
-- tests/actions/vstudio/vc2010/test_extension_settings.lua
-- Check the import extension settings block of a VS 2010 project.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_extension_settings")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks

	function suite.setup()
		p.action.set("vs2010")
		rule "MyRules"
		rule "MyOtherRules"
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = test.getproject(wks)
		vc2010.importExtensionSettings(prj)
	end


--
-- Writes an empty element when no custom rules are specified.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionSettings">
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
<ImportGroup Label="ExtensionSettings">
	<Import Project="MyRules.props" />
	<Import Project="MyOtherRules.props" />
</ImportGroup>
		]]
	end


--
-- Rule files use a project relative path.
--

	function suite.usesProjectRelativePaths()
		rules "MyRules"
		location "build"
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionSettings">
	<Import Project="..\MyRules.props" />
</ImportGroup>
		]]
	end

--
-- the asm 'file category' should add the right settings.
--

	function suite.hasAssemblyFiles()
		files { "test.asm" }
		location "build"
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionSettings">
	<Import Project="$(VCTargetsPath)\BuildCustomizations\masm.props" />
</ImportGroup>
		]]
	end
