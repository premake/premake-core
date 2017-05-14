--
-- tests/actions/vstudio/vc2010/test_extension_targets.lua
-- Check the import extension targets block of a VS 2010 project.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_extension_targets")
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
-- Writes entries for NuGet packages.
--

	function suite.addsImport_onEachNuGetPackage()
		nuget { "boost:1.59.0-b1", "sdl2.v140:2.0.3", "sdl2.v140.redist:2.0.3" }
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
	<Import Project="packages\boost.1.59.0-b1\build\native\boost.targets" Condition="Exists('packages\boost.1.59.0-b1\build\native\boost.targets')" />
	<Import Project="packages\sdl2.v140.2.0.3\build\native\sdl2.v140.targets" Condition="Exists('packages\sdl2.v140.2.0.3\build\native\sdl2.v140.targets')" />
	<Import Project="packages\sdl2.v140.redist.2.0.3\build\native\sdl2.v140.redist.targets" Condition="Exists('packages\sdl2.v140.redist.2.0.3\build\native\sdl2.v140.redist.targets')" />
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


--
-- the asm 'file category' should add the right target.
--

	function suite.hasAssemblyFiles()
		files { "test.asm" }
		location "build"
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
	<Import Project="$(VCTargetsPath)\BuildCustomizations\masm.targets" />
</ImportGroup>
		]]
	end
