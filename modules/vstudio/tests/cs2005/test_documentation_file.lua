--
-- tests/actions/vstudio/cs2005/test_debug_props.lua
-- Test debugging and optimization flags block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--
	local p = premake
	local suite = test.declare("vstudio_cs2005_documentation_file")
	local dn2005 = p.vstudio.dotnetbase
--
-- Setup
--

	local wks, prj

--
-- Setup and teardown
--
	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
		configurations { "Debug", "Release" }
		-- project "documentationFile"
		language "C#"
		targetdir("test\\targetDir")
	end

	local function setConfig()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.documentationFile(cfg);
	end



	local function prepare()
		prj = test.getproject(wks, 1)
	end

	local function prepareEmpty()
		prepare()
		documentationFile ""
		setConfig()
	end

	local function prepareDir()
		prepare()
		documentationFile "test"
		setConfig()
	end

--
-- Test Eempty and Nil
--

function suite.documentationFileEmpty()
	prepareEmpty()
	test.capture [[
		<DocumentationFile>test\targetDir\MyProject.xml</DocumentationFile>
		]]
end

function suite.documentationFilePath()
	prepareDir()
	test.capture [[
		<DocumentationFile>test\MyProject.xml</DocumentationFile>
		]]

end

