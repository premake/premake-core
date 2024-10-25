--
-- tests/actions/vstudio/vc2010/test_item_def_group.lua
-- Check the item definition groups, containing compile and link flags.
-- Copyright (c) 2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_item_def_group")
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

	local function prepare(buildcfg)
		local cfg = test.getconfig(prj, buildcfg or "Debug")
		vc2010.itemDefinitionGroup(cfg)
	end


--
-- Check generation of opening element for typical C++ project.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		]]
	end


--
-- Makefile projects omit the condition and all contents.
--

	function suite.structureIsCorrect_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
<ItemDefinitionGroup>
</ItemDefinitionGroup>
		]]
	end

	function suite.structureIsCorrect_onNone()
		kind "Makefile"
		prepare()
		test.capture [[
<ItemDefinitionGroup>
</ItemDefinitionGroup>
		]]
	end



--
-- Because the item definition group for makefile projects is not
-- tied to a particular condition, it should only get written for
-- the first configuration.
--

	function suite.skipped_onSubsequentConfigs()
		kind "Makefile"
		prepare("Release")
		test.isemptycapture()
	end

	function suite.skipped_onSubsequentConfigs_onNone()
		kind "None"
		prepare("Release")
		test.isemptycapture()
	end

--
-- Utility projects include buildlog
--
	function suite.utilityIncludesPath()
		kind "Utility"
		buildlog "MyCustomLogFile.log"
		prepare()
		test.capture [[
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<BuildLog>
		<Path>MyCustomLogFile.log</Path>
	</BuildLog>
</ItemDefinitionGroup>
		]]
	end
