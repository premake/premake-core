--
-- tests/actions/make/cpp/test_wiidev.lua
-- Tests for Wii homebrew support in makefiles.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_wiidev")
	local make = premake.make
	local project = premake.project


--
-- Setup
--

	local cfg

	function suite.setup()
		local wks, prj = test.createWorkspace()
		system "wii"
		flags "Symbols"
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Make sure that the Wii-specific flags are passed to the tools.
--

	function suite.writesCorrectCppFlags()
		make.cppFlags(cfg, premake.tools.gcc)
		test.capture [[
  ALL_CPPFLAGS += $(CPPFLAGS) -MMD -MP -I$(LIBOGC_INC) $(MACHDEP) $(DEFINES) $(INCLUDES)
  		]]
	end

	function suite.writesCorrectLinkerFlags()
		make.ldFlags(cfg, premake.tools.gcc)
		test.capture [[
  ALL_LDFLAGS += $(LDFLAGS) -L$(LIBOGC_LIB) $(MACHDEP)
		]]
	end


--
-- Make sure the dev kit include is written to each Wii build configuration.
--

	function suite.writesIncludeBlock()
		make.settings(cfg, premake.tools.gcc)
		test.capture [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules'
		]]
	end
