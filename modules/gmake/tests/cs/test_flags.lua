--
-- tests/actions/make/cs/test_flags.lua
-- Tests compiler and linker flags for C# Makefiles.
-- Copyright (c) 2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_cs_flags")
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
		make.csFlags(cfg, p.tools.dotnet)
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
		clr "Unsafe"
		prepare()
		test.capture [[
  FLAGS = /unsafe /noconfig
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
