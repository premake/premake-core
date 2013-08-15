--
-- tests/actions/vs2013/test_csproj_project_element.lua
-- Check generation of opening project element for VS2013 C# projects.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2013_csproj_project_element")
	local cs2005 = premake.vstudio.cs2005


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2013"
		sln, prj = test.createsolution()
	end


	function suite.allVersionsCorrect()
		cs2005.projectElement(prj)
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end
