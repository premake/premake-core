--
-- tests/actions/make/cpp/test_wiidev.lua
-- Tests for Wii homebrew support in makefiles.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.make_wiidev = {}
	local suite = T.make_wiidev
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
		system "wii"
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Make sure that the Wii-specific flags are passed to the tools.
--

	function suite.writesCorrectFlags()
		cpp.flags(cfg, premake.tools.gcc)
		test.capture [[
  DEFINES   +=
  INCLUDES  +=
  ALL_CPPFLAGS += $(CPPFLAGS) -MMD -MP -I$(LIBOGC_INC) $(MACHDEP) $(DEFINES) $(INCLUDES)
  ALL_CFLAGS   += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH)
  ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_LDFLAGS  += $(LDFLAGS) -s -L$(LIBOGC_LIB) $(MACHDEP)
  ALL_RESFLAGS += $(RESFLAGS) $(DEFINES) $(INCLUDES)
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
