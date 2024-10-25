--
-- tests/actions/vstudio/dotnet2005/projectelement.lua
-- Validate generation of <Project/> element in Visual Studio 2005+ .csproj
-- Copyright (c) 2009-2017 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_dn2005_projectelement")
	local dn2005 = p.vstudio.dotnetbase


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		dn2005.xmlDeclaration()
		dn2005.projectElement(prj)
	end


--
-- Tests
--

	function suite.on2005()
		p.action.set("vs2005")
		prepare()
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2008()
		p.action.set("vs2008")
		prepare()
		test.capture [[
<Project ToolsVersion="3.5" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2010()
		p.action.set("vs2010")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2012()
		p.action.set("vs2012")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end


	function suite.on2013()
		p.action.set("vs2013")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.on2015()
		p.action.set("vs2015")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="14.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.on2017()
		p.action.set("vs2017")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.on2019()
		p.action.set("vs2019")
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end
