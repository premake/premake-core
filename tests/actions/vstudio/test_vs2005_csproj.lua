--
-- tests/actions/test_vs2005_csproj.lua
-- Automated test suite for Visual Studio 2005-2008 C# project generation.
-- Copyright (c) 2010 Jason Perkins and the Premake project
--

	T.vs2005_csproj = { }
	local suite = T.vs2005_csproj
	local cs2005 = premake.vstudio.cs2005

--
-- Configure a solution for testing
--

	local sln, prj
	function suite.setup()
		_ACTION = "vs2005"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project "MyProject"
		language "C#"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
	end


--
-- Project header tests
--

	function suite.projectheader_OnVs2005()
		_ACTION = "vs2005"
		prepare()
		cs2005.projectheader(prj)
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.projectheader_OnVs2008()
		_ACTION = "vs2008"
		prepare()
		cs2005.projectheader(prj)
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="3.5">
		]]
	end
