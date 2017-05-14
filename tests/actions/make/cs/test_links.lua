--
-- tests/actions/make/cs/test_links.lua
-- Tests linking for C# Makefiles.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_cs_links")
	local make = p.make
	local cs = p.make.cs
	local project = p.project

--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		make.csLinkCmd(cfg, p.tools.dotnet)
	end


--
-- Should return an empty assignment if nothing has been specified.
--

	function suite.isEmptyAssignment_onNoSettings()
		prepare()
		test.capture [[
  DEPENDS =
		]]
	end


--
-- Files that can be compiled should be listed here.
--

	function suite.doesListLinkDependencyFiles()
		links { "MyProject2", "MyProject3" }

		test.createproject(wks)
		kind "SharedLib"
		language "C#"

		test.createproject(wks)
		kind "SharedLib"
		language "C#"

		prepare ()
		test.capture [[
  DEPENDS = bin/Debug/MyProject2.dll bin/Debug/MyProject3.dll
		]]
	end
