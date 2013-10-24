--
-- tests/actions/make/cs/test_links.lua
-- Tests linking for C# Makefiles.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

    local suite = test.declare("make_cs_links")
    local make = premake.make
    local cs = premake.make.cs
    local project = premake.project

--
-- Setup
--

    local sln, prj, cfg

    function suite.setup()
        sln, prj = test.createsolution()
    end

    local function prepare()
        prj = premake.solution.getproject(sln, 1)
        cfg = project.getconfig(prj, "Debug")
        make.csLinkCmd(cfg, premake.tools.dotnet)
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

        test.createproject(sln)
        kind "SharedLib"
        language "C#"

        test.createproject(sln)
        kind "SharedLib"
        language "C#"

        prepare ()
        test.capture [[
  DEPENDS = MyProject2.dll MyProject3.dll
        ]]
    end
