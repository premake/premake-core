--
-- tests/actions/vstudio/cs2005/test_targets.lua
-- Check Visual Studio 2012 extensions to the targets block.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2012_csproj_targets")
	local cs2005 = premake.vstudio.cs2005


--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2012")
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cs2005.targets(prj)
	end


---
-- Visual Studio 2012 changes the MS Build path slightly.
---

	function suite.on2012()
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
