--
-- tests/actions/vstudio/cs2005/test_nuget_references.lua
-- Validate generation of NuGet package references files for Visual Studio 2010 and newer
-- Copyright (c) 2017 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_nuget_references")
	local dn2005 = p.vstudio.dotnetbase
	local nuget2010 = p.vstudio.nuget2010


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		_OPTIONS.os = "macosx"
		p.action.set("vs2010")
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		dn2005.nuGetReferences(prj)
	end

--
-- Check that we process Unix-style paths correctly.
--

if _OPTIONS["test-all"] then
	function suite.unixPaths()
		dotnetframework "4.6"
		nuget "Mono.Cecil:0.9.6.4"
		prepare()
	end
end
