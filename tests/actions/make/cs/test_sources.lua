--
-- tests/actions/make/cs/test_sources.lua
-- Tests source file listings for C# Makefiles.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("make_cs_sources")
	local make = premake.make
	local cs = premake.make.cs
	local project = premake.project


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = premake.workspace.getproject(wks, 1)
		make.csSources(prj, premake.tools.dotnet)
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
