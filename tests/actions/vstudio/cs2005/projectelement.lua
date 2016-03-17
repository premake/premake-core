--
-- tests/actions/vstudio/cs2005/projectelement.lua
-- Validate generation of <Project/> element in Visual Studio 2005+ .csproj
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_cs2005_projectelement")
	local cs2005 = premake.vstudio.cs2005


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		cs2005.xmlDeclaration()
		cs2005.projectElement(prj)
	end


--
-- Tests
--

	function suite.on2005()
		premake.action.set("vs2005")
		prepare()
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2008()
		premake.action.set("vs2008")
		prepare()
		test.capture [[
<Project ToolsVersion="3.5" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2010()
		premake.action.set("vs2010")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2012()
		premake.action.set("vs2012")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2013()
		premake.action.set("vs2013")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end
