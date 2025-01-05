--
-- test_gmake_ldflags.lua
-- Tests compiler and linker flags for Makefiles.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake_ldflags")

	local p = premake
	local gmake = p.modules.gmake


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
		gmake.cpp.ldFlags(cfg, toolset)
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
