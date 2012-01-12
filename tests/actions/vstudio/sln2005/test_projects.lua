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

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2005"
		sln, prj = test.createsolution()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
	end
	
	local function prepare()
		sln2005.project_ng(prj)
	end


--
-- Check the format of a C/C++ project entry
--

	function suite.structureIsOkay_onCpp()
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
		]]
	end


--
-- Check the format of a VS2005/V2008 C# project entry
--

	function suite.structureIsOkay_onCSharp()
		language "C#"
		prepare()
		test.capture [[
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "MyProject", "MyProject.csproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
		]]
	end


--
-- Project names should be XML escaped.
--

	function suite.projectNamesAreEscaped()
		prj.name = 'My "x64" Project';
		prepare()
		test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "My &quot;x64&quot; Project", "My &quot;x64&quot; Project.vcproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
		]]
	end
