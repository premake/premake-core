--
-- tests/actions/make/cpp/test_ldflags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("make_ldflags")
	local make = premake.make


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
		flags("Symbols")
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = premake.tools.gcc
		make.ldFlags(cfg, toolset)
	end


--
-- Check the output from default project values.
--

	function suite.checkDefaultValues()
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS)
		]]
	end

--
-- Check addition of library search directores.
--

	function suite.checkLibDirs()
		libdirs { "../libs", "libs" }
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -L../libs -Llibs
		]]
	end
