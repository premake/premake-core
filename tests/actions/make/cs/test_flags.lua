--
-- tests/actions/make/cs/test_flags.lua
-- Tests compiler and linker flags for C# Makefiles.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_cs_flags")
	local make = premake.make
	local cs = premake.make.cs
	local project = premake.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
		make.csFlags(cfg, premake.tools.dotnet)
	end


--
-- Should return an empty assignment if nothing has been specified.
--

	function suite.isEmptyAssignment_onNoSettings()
		prepare()
		test.capture [[
  FLAGS =
  		]]
  	end


--
-- If an application icon has been set, it should be specified.
--

	function suite.onApplicationIcon()
		icon "MyProject.ico"
		prepare()
		test.capture [[
  FLAGS = /win32icon:"MyProject.ico"
  		]]
  	end
