--
-- tests/actions/make/cs/test_sources.lua
-- Tests source file listings for C# Makefiles.
-- Copyright (c) 2013-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_cs_sources")
	local make = p.makelegacy
	local cs = p.makelegacy.cs
	local project = p.project


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = p.workspace.getproject(wks, 1)
		make.csSources(prj, p.tools.dotnet)
	end


--
-- Files that can be compiled should be listed here.
--

	function suite.doesListSourceFiles()
		files { "Hello.cs" }
		prepare()
		test.capture [[
SOURCES += \
	Hello.cs \

		]]
	end

--
-- Path delimiter uses slash instead of backslash
--

	function suite.doesUseProperPathDelimiter()
		files { "Folder\\Hello.cs", "Folder/World.cs" }
		prepare()
		test.capture [[
SOURCES += \
	Folder/Hello.cs \
	Folder/World.cs \

		]]
	end


--
-- Files that should not be compiled should be excluded.
--

	function suite.doesIgnoreNonSourceFiles()
		files { "About.txt", "Hello.cs" }
		prepare()
		test.capture [[
SOURCES += \
	Hello.cs \

		]]
	end


--
-- Files with a non-standard file extension but a build action of
-- "Compile" should be listed here.
--

	function suite.doesIncludeCompileBuildAction()
		files { "Hello.txt" }
		filter "files:*.txt"
		buildaction "Compile"
		prepare()
		test.capture [[
SOURCES += \
	Hello.txt \

		]]
	end
