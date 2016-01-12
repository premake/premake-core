--
-- tests/actions/vstudio/sln2005/test_sections.lua
-- Validate generation of Visual Studio 2005+ solution section entries.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_sln2005_sections")
	local sln2005 = premake.vstudio.sln2005


--
-- Setup
--

	local wks

	function suite.setup()
		_MAIN_SCRIPT = "c:\\test\\premake5.lua"

		premake.escaper(premake.vstudio.vs2005.esc)
		wks = workspace("MyWorkspace")
		wks.location = "c:\\test\\build"

		configurations { "Debug", "Release" }
		language "C++"
		kind "ConsoleApp"
	end

--
-- Test the editorintegration switch.
--
	function suite.extensibilityGlobalsOn()
		editorintegration "On"

		project "MyProject"
		sln2005.extensibilityGlobals(wks)

		test.capture [[
GlobalSection(ExtensibilityGlobals) = postSolution
]]
	end

	function suite.extensibilityGlobalsOff()
		editorintegration "Off"

		project "MyProject"
		sln2005.extensibilityGlobals(wks)

		local res = premake.captured()
		if (#res > 0) then
			test.fail("no editorintegration output was expected");
		end
	end
