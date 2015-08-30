--
-- tests/actions/make/cs/test_embed_files.lua
-- Tests embedded file listings for C# Makefiles.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("make_cs_embed_files")
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
		make.csEmbedFiles(prj, premake.tools.dotnet)
	end


--
-- Files that can be compiled should be listed here.
--

	function suite.doesListResourceFiles()
		files { "Hello.resx" }
		prepare()
		test.capture [[
EMBEDFILES += \
	$(OBJDIR)/MyProject.Hello.resources \

  		]]
  	end


--
-- Files that should not be compiled should be excluded.
--

	function suite.doesIgnoreNonResourceFiles()
		files { "About.txt", "Hello.resx" }
		prepare()
		test.capture [[
EMBEDFILES += \
	$(OBJDIR)/MyProject.Hello.resources \

  		]]
  	end


--
-- Files with a non-standard file extension but a build action of
-- "Embed" should be listed here.
--

	function suite.doesIncludeCompileBuildAction()
		files { "Hello.txt" }
		filter "files:*.txt"
		buildaction "Embed"
		prepare()
		test.capture [[
EMBEDFILES += \
	Hello.txt \

  		]]
  	end
