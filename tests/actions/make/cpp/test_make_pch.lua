--
-- tests/actions/make/cpp/test_make_pch.lua
-- Validate the setup for precompiled headers in makefiles.
-- Copyright (c) 2010-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_pch")
	local make = premake.make
	local project = premake5.project



--
-- Setup and teardown
--

	local sln, prj, cfg
	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepareVars()
		cfg = project.getconfig(prj, "Debug")
		make.pch(cfg)
	end

	local function prepareRules()
		cfg = project.getconfig(prj, "Debug")
		make.pchRules(cfg.project)
	end


--
-- If no header has been set, nothing should be output.
--

	function suite.noConfig_onNoHeaderSet()
		prepareVars()
		test.isemptycapture()
	end


--
-- If a header is set, but the NoPCH flag is also set, then
-- nothing should be output.
--

	function suite.noConfig_onHeaderAndNoPCHFlag()
		pchheader "include/myproject.h"
		flags "NoPCH"
		prepareVars()
		test.isemptycapture()
	end


--
-- If a header is specified and the NoPCH flag is not set, then
-- the header can be used.
--

	function suite.config_onPchEnabled()
		pchheader "include/myproject.h"
		prepareVars()
		test.capture [[
  PCH = include/myproject.h
  GCH = $(OBJDIR)/$(notdir $(PCH)).gch
		]]
	end


--
-- The PCH can be specified relative the an includes search path.
--

	function suite.pch_searchesIncludeDirs()
		pchheader "premake.h"
		includedirs { "../src/host" }
		prepareVars()
		test.capture [[
  PCH = ../src/host/premake.h
		]]
	end


--
-- Verify the format of the PCH rules block for a C++ file.
--

	function suite.buildRules_onCpp()
		pchheader "include/myproject.h"
		prepareRules()
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	$(SILENT) $(CXX) -x c++-header $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES) -o "$@" -MF "$(@:%.gch=%.d)" -c "$<"
endif
		]]
	end


--
-- Verify the format of the PCH rules block for a C file.
--

	function suite.buildRules_onC()
		language "C"
		pchheader "include/myproject.h"
		prepareRules()
		test.capture [[
ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	$(SILENT) $(CC) -x c-header $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES) -o "$@" -MF "$(@:%.gch=%.d)" -c "$<"
endif
		]]
	end
