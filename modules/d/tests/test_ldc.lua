---
-- d/tests/test_dmd.lua
-- Automated test suite for dmd.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("d_ldc")
	local p = premake
	local m = p.modules.d

	local make = p.make
	local project = p.project


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		p.escaper(make.esc)
		wks = test.createWorkspace()
	end

	local function prepare_cfg(calls)
		prj = p.workspace.getproject(wks, 1)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = p.tools.ldc
		p.callArray(calls, cfg, toolset)
	end


--
-- Check configuration generation
--

	function suite.dmd_dTools()
		prepare_cfg({ m.make.dTools })
		test.capture [[
  DC = ldc2
		]]
	end

	function suite.dmd_target()
		prepare_cfg({ m.make.target })
		test.capture [[

		]]
	end

	function suite.dmd_target_separateCompilation()
		flags { "SeparateCompilation" }
		prepare_cfg({ m.make.target })
		test.capture [[
  OUTPUTFLAG = -of="$@"
		]]
	end

	function suite.dmd_versions()
		versionlevel (10)
		versionconstants { "A", "B" }
		prepare_cfg({ m.make.versions })
		test.capture [[
  VERSIONS += -d-version=A -d-version=B -d-version=10
		]]
	end

	function suite.dmd_debug()
		debuglevel (10)
		debugconstants { "A", "B" }
		prepare_cfg({ m.make.debug })
		test.capture [[
  DEBUG += -d-debug=A -d-debug=B -d-debug=10
		]]
	end

	function suite.dmd_imports()
		includedirs { "dir1", "dir2/" }
		prepare_cfg({ m.make.imports })
		test.capture [[
  IMPORTS += -I=dir1 -I=dir2
		]]
	end

	function suite.dmd_dFlags()
		prepare_cfg({ m.make.dFlags })
		test.capture [[
  ALL_DFLAGS += $(DFLAGS) -release $(VERSIONS) $(DEBUG) $(IMPORTS) $(ARCH)
		]]
	end

	function suite.dmd_linkCmd()
		prepare_cfg({ m.make.linkCmd })
		test.capture [[
  BUILDCMD = $(DC) -of=$(TARGET) $(ALL_DFLAGS) $(ALL_LDFLAGS) $(LIBS) $(SOURCEFILES)
		]]
	end

	function suite.dmd_linkCmd_separateCompilation()
		flags { "SeparateCompilation" }
		prepare_cfg({ m.make.linkCmd })
		test.capture [[
  LINKCMD = $(DC) -of=$(TARGET) $(ALL_LDFLAGS) $(LIBS) $(OBJECTS)
		]]
	end
