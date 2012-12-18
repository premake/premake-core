--
-- tests/actions/vstudio/sln2005/test_projects.lua
-- Validate generation of Visual Studio 2005+ solution project entries.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_sln2005_projects = { }
	local suite = T.vstudio_sln2005_projects
	local sln2005 = premake.vstudio.sln2005


--
-- Setup 
--

	local sln
	
	function suite.setup()
		_ACTION = "vs2008"
		sln = solution "MySolution"
		configurations { "Debug", "Release" }		
	end
	
	local function prepare()
		sln2005.projects(sln)
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
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Alpha", "Alpha", "{0B5CD40C-7770-FCBD-40F2-9F1DACC5F8EE}"
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
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Alpha", "Alpha", "{0B5CD40C-7770-FCBD-40F2-9F1DACC5F8EE}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Beta", "Beta", "{96080FE9-82C0-5036-EBC7-2992D79EEB26}"
EndProject
		]]
	end
