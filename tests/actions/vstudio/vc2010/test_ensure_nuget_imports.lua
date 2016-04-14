--
-- tests/actions/vstudio/vc2010/test_ensure_nuget_imports.lua
-- Check the EnsureNuGetPackageBuildImports block of a VS 2010 project.
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_ensure_nuget_imports")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = premake.solution.getproject(wks, 1)
		vc2010.ensureNuGetPackageBuildImports(prj)
	end


--
-- Should not output anything if no packages have been set.
--

	function suite.noOutputIfNoPackages()
		prepare()
		test.isemptycapture()
	end



--
-- Writes the pre-build check that makes sure that all packages are installed.
--

	function suite.structureIsCorrect()
		nuget { "boost:1.59.0-b1", "sdl2.v140:2.0.3", "sdl2.v140.redist:2.0.3" }
		prepare()
		test.capture [[
<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
	<PropertyGroup>
		<ErrorText>This project references NuGet package(s) that are missing on this computer. Use NuGet Package Restore to download them.  For more information, see http://go.microsoft.com/fwlink/?LinkID=322105. The missing file is {0}.</ErrorText>
	</PropertyGroup>
	<Error Condition="!Exists('packages\boost.1.59.0-b1\build\native\boost.targets')" Text="$([System.String]::Format('$(ErrorText)', 'packages\boost.1.59.0-b1\build\native\boost.targets'))" />
	<Error Condition="!Exists('packages\sdl2.v140.2.0.3\build\native\sdl2.v140.targets')" Text="$([System.String]::Format('$(ErrorText)', 'packages\sdl2.v140.2.0.3\build\native\sdl2.v140.targets'))" />
	<Error Condition="!Exists('packages\sdl2.v140.redist.2.0.3\build\native\sdl2.v140.redist.targets')" Text="$([System.String]::Format('$(ErrorText)', 'packages\sdl2.v140.redist.2.0.3\build\native\sdl2.v140.redist.targets'))" />
</Target>
		]]
	end
