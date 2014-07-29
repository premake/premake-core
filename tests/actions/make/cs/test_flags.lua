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

	local sln, prj

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		make.csFlags(cfg, premake.tools.dotnet)
	end


--
-- Should return an empty assignment if nothing has been specified.
--

	function suite.isEmptyAssignment_onNoSettings()
		prepare()
		test.capture [[
  FLAGS = /noconfig
  		]]
  	end

--
-- If the Unsafe flag has been set, it should be specified.
--

	function suite.onUnsafe()
		flags { "Unsafe" }
		prepare()
		test.capture [[
  FLAGS = /noconfig /unsafe
  		]]
  	end


--
-- If an application icon has been set, it should be specified.
--

	function suite.onApplicationIcon()
		icon "MyProject.ico"
		prepare()
		test.capture [[
  FLAGS = /noconfig /win32icon:"MyProject.ico"
  		]]
  	end
