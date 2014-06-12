--
-- tests/actions/vstudio/vc2010/test_extension_settings.lua
-- Check the import extension settings block of a VS 2010 project.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_import_settings")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local sln

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		local prj = test.getproject(sln)
		vc2010.importExtensionSettings(prj)
	end


--
-- Writes an empty element when no custom rules are specified.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
<ImportGroup Label="ExtensionSettings">
</ImportGroup>
		]]
	end



--
-- Writes entries for each project scoped custom rules path.
--

	function suite.addsImport_onEachRulesFile()
		customRules "MyRules"
		customRules "MyOtherRules"
		prepare()
		test.capture [[
<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
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
		customRules "path/to/MyRules"
		location "build"
		prepare()
		test.capture [[
<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
<ImportGroup Label="ExtensionSettings">
	<Import Project="..\path\to\MyRules.props" />
</ImportGroup>
		]]
	end
