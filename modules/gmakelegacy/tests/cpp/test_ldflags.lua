--
-- tests/actions/make/cpp/test_ldflags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_ldflags")
	local make = p.makelegacy


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
		symbols "On"
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = p.tools.gcc
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
-- Check addition of library search directories.
--

	function suite.checkLibDirs()
		libdirs { "../libs", "libs" }
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -L../libs -Llibs
		]]
	end

	function suite.checkLibDirs_X86_64()
		architecture ("x86_64")
		system (p.LINUX)
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -L/usr/lib64 -m64
		]]
	end

	function suite.checkLibDirs_X86()
		architecture ("x86")
		system (p.LINUX)
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -L/usr/lib32 -m32
		]]
	end

	function suite.checkLibDirs_X86_64_MacOSX()
		architecture ("x86_64")
		system (p.MACOSX)
		prepare()
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -m64
		]]
	end
