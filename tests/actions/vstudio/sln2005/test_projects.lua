--
-- tests/actions/vstudio/sln2005/test_projects.lua
-- Validate generation of Visual Studio 2005+ solution project entries.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_sln2005_projects")
	local sln2005 = premake.vstudio.sln2005


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2005")
		premake.escaper(premake.vstudio.vs2005.esc)
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		language "C++"
		kind "ConsoleApp"
	end

	local function prepare()
		sln2005.reorderProjects(wks)
		sln2005.projects(wks)
	end


--
-- Check the format of a C/C++ project entry
--

	function suite.structureIsOkay_onCpp()
		project "MyProject"
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
		]]
	end


--
-- Check the format of a VS2005/V2008 C# project entry
--

	function suite.structureIsOkay_onCSharp()
		project "MyProject"
		language "C#"
		prepare()
		test.capture [[
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "MyProject", "MyProject.csproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
		]]
	end


--
-- Project names should be XML escaped.
--

	function suite.projectNamesAreEscaped()
		project 'My "x64" Project'
		filename 'My "x64" Project'
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "My &quot;x64&quot; Project", "My &quot;x64&quot; Project.vcproj", "{48E4ED8F-34DD-0CE2-5D0F-F2664967ECED}"
EndProject
		]]
	end


--
-- Check the structure of a top-level group entry.
--

	function suite.onSingleTopLevelGroup()
		group "Alpha"
		project "MyProject"
		prepare()
		test.capture [[
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Alpha", "Alpha", "{D2C41116-3E7A-8A0B-C76E-84E23323810F}"
EndProject
		]]
	end



--
-- Nested groups should be listed individually.
--

	function suite.OnNestedGroups()
		group "Alpha/Beta"
		project "MyProject"
		prepare()
		test.capture [[
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Alpha", "Alpha", "{D2C41116-3E7A-8A0B-C76E-84E23323810F}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Beta", "Beta", "{BD0520A9-A9FE-3EFB-D230-2480BE881E07}"
EndProject
		]]
	end


--
-- If a startup project is specified, it should appear first in the list.
--

	function suite.startupProjectFirst_onNoGroups()
		startproject "MyProject2"
		project "MyProject1"
		project "MyProject2"
		project "MyProject3"
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject2", "MyProject2.vcproj", "{B45D52A2-A015-94EF-091D-6D4BF5F32EE0}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject1", "MyProject1.vcproj", "{B35D52A2-9F15-94EF-081D-6D4BF4F32EE0}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject3", "MyProject3.vcproj", "{B55D52A2-A115-94EF-0A1D-6D4BF6F32EE0}"
EndProject
		]]
	end


--
-- If the startup project is contained by a group, that group (and any parent
-- groups) should appear first in the list.
--

	function suite.startupProjectFirst_onSingleGroup()
		startproject "MyProject2"
		project "MyProject1"
		group "Zed"
		project "MyProject2"
		group "Beta"
		project "MyProject3"
		prepare()
		test.capture [[
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Zed", "Zed", "{2FCAF67E-9B34-ABF5-E472-5C9B501C894A}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject2", "MyProject2.vcproj", "{B45D52A2-A015-94EF-091D-6D4BF5F32EE0}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject1", "MyProject1.vcproj", "{B35D52A2-9F15-94EF-081D-6D4BF4F32EE0}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Beta", "Beta", "{68E9C25D-54A1-04AB-BDA8-DD06A97F9F9B}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject3", "MyProject3.vcproj", "{B55D52A2-A115-94EF-0A1D-6D4BF6F32EE0}"
EndProject
		]]
	end

	function suite.startupProjectFirst_onMultipleGroups()
		startproject "MyProject2"
		project "MyProject1"
		group "Zed"
		project "MyProject3"
		group "Alpha/Beta"
		project "MyProject2"
		prepare()
		test.capture [[
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Alpha", "Alpha", "{D2C41116-3E7A-8A0B-C76E-84E23323810F}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Beta", "Beta", "{BD0520A9-A9FE-3EFB-D230-2480BE881E07}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject2", "MyProject2.vcproj", "{B45D52A2-A015-94EF-091D-6D4BF5F32EE0}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject1", "MyProject1.vcproj", "{B35D52A2-9F15-94EF-081D-6D4BF4F32EE0}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Zed", "Zed", "{2FCAF67E-9B34-ABF5-E472-5C9B501C894A}"
EndProject
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject3", "MyProject3.vcproj", "{B55D52A2-A115-94EF-0A1D-6D4BF6F32EE0}"
EndProject
		]]
	end


--
-- Environment variables in the form of $(...) need to be translated
-- to old school %...% DOS style.
--

	function suite.translatesEnvironmentVars()
		externalproject "MyProject"
		location "$(SDK_LOCATION)/MyProject"
		uuid "30A1B994-C2C6-485F-911B-FB4674366DA8"
		kind "SharedLib"
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "%SDK_LOCATION%\MyProject\MyProject.vcproj", "{30A1B994-C2C6-485F-911B-FB4674366DA8}"
EndProject
		]]
	end
