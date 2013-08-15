--
-- tests/actions/vs2013/test_csproj_targets.lua
-- Check Visual Studio 2013 extensions to the targets block.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2013_csproj_targets")
	local cs2005 = premake.vstudio.cs2005


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2013"
		sln = test.createsolution()
		language "C#"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cs2005.targets(prj)
	end


---
-- Visual Studio 2013 changes the MS Build path slightly.
---

	function suite.onDefaultCommonProps()
		prepare()
		test.capture [[
	<Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
	<!-- To modify your build process, add your task inside one of the targets below and uncomment it.
	     Other similar extension points exist, see Microsoft.Common.targets.
	<Target Name="BeforeBuild">
	</Target>
	<Target Name="AfterBuild">
	</Target>
	-->
	]]
	end
