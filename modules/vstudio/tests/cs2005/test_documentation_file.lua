--
-- tests/actions/vstudio/cs2005/test_documentation_file.lua
-- Test DocumentationFile feature Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2023 Jason Perkins and the Premake project
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
		language "C#"
		targetdir("test\\targetDir")
	end

	local function setConfig()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.documentationfile(cfg);
	end



	local function prepare()
		prj = test.getproject(wks, 1)
	end

	local function prepareEmpty()
		prepare()
		documentationfile ""
		setConfig()
	end

	local function prepareDir()
		prepare()
		documentationfile "test"
		setConfig()
	end

	local function prepareNull()
		p.action.set("vs2010")
		wks = test.createWorkspace()
		setConfig()
	end

function suite.documentationFilePath()
	prepareDir()
	test.capture [[
		<DocumentationFile>test\MyProject.xml</DocumentationFile>
		]]
end

function suite.documentationFilePath_vs2017up()
	p.action.set("vs2017")
	prepareDir()
	test.capture [[
		<DocumentationFile>test\MyProject.xml</DocumentationFile>
		]]
end

function suite.documentationEmpty()
	prepareEmpty()
	test.capture [[
		<DocumentationFile>test\targetDir\MyProject.xml</DocumentationFile>
		]]
end

function suite.documentationEmpty_vs2017up()
	p.action.set("vs2017")
	prepareEmpty()
	test.capture [[<GenerateDocumentationFile>true</GenerateDocumentationFile>]]
end

function suite.documentationNull()
	prepareNull()
	test.isemptycapture()
end


