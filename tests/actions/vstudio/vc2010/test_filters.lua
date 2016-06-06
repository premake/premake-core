--
-- tests/actions/vstudio/vc2010/test_filters.lua
-- Validate generation of file filter blocks in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_filters")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare(group)
		prj = test.getproject(wks)
		vc2010.filterGroups(prj)
	end


--
-- Check contents of the different file groups.
--

	function suite.itemGroup_onClInclude()
		files { "hello.h" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClInclude Include="hello.h" />
</ItemGroup>
		]]
	end

	function suite.itemGroup_onResourceSection()
		files { "hello.rc" }
		prepare()
		test.capture [[
<ItemGroup>
	<ResourceCompile Include="hello.rc" />
</ItemGroup>
		]]
	end

	function suite.itemGroup_onNoneSection()
		files { "hello.txt" }
		prepare()
		test.capture [[
<ItemGroup>
	<None Include="hello.txt" />
</ItemGroup>
		]]
	end

	function suite.itemGroup_onMixed()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClInclude Include="hello.h" />
</ItemGroup>
<ItemGroup>
	<ClCompile Include="hello.c" />
</ItemGroup>
<ItemGroup>
	<None Include="hello.txt" />
</ItemGroup>
<ItemGroup>
	<ResourceCompile Include="hello.rc" />
</ItemGroup>
		]]
	end


--
-- Files with a build rule go into a custom build section.
--

	function suite.itemGroup_onBuildRule()
		files { "hello.cg" }
		filter "files:**.cg"
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare("CustomBuild")
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg" />
</ItemGroup>
		]]
	end

	function suite.itemGroup_onSingleConfigBuildRule()
		files { "hello.cg" }
		filter { "Release", "files:**.cg" }
			buildcommands { "cgc $(InputFile)" }
			buildoutputs { "$(InputName).obj" }
		prepare("CustomBuild")
		test.capture [[
<ItemGroup>
	<CustomBuild Include="hello.cg" />
</ItemGroup>
		]]
	end


--
-- Files located at the root (in the same folder as the project) do not
-- need a filter identifier.
--

	function suite.noFilter_onRootFiles()
		files { "hello.c", "goodbye.c" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="goodbye.c" />
	<ClCompile Include="hello.c" />
</ItemGroup>
		]]
	end

--
-- Check the filter with a real path.
--

	function suite.filter_onRealPath()
		files { "src/hello.c", "hello.h" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClInclude Include="hello.h" />
</ItemGroup>
<ItemGroup>
	<ClCompile Include="src\hello.c">
		<Filter>src</Filter>
	</ClCompile>
</ItemGroup>
		]]
	end

--
-- Check the filter with a virtual path.
--

	function suite.filter_onVpath()
		files { "src/hello.c", "hello.h" }
		vpaths { ["Source Files"] = "**.c" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClInclude Include="hello.h" />
</ItemGroup>
<ItemGroup>
	<ClCompile Include="src\hello.c">
		<Filter>Source Files</Filter>
	</ClCompile>
</ItemGroup>
		]]
	end


--
-- Check handling of files using custom rules.
--

	function suite.filter_onCustomRule()
		rules "Animation"
		files { "hello.dae" }

		rule "Animation"
		fileextension ".dae"

		prepare()
		test.capture [[
<ItemGroup>
	<Animation Include="hello.dae" />
</ItemGroup>
		]]
	end


--
-- Check handling of .asm files
--
	function suite.itemGroup_onNoneSection()
		files { "hello.asm" }
		prepare()
		test.capture [[
<ItemGroup>
	<Masm Include="hello.asm" />
</ItemGroup>
		]]
	end
