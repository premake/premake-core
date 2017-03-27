--
-- tests/actions/make/cpp/test_target_rules.lua
-- Validate the makefile target building rules.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_cpp_target_rules")
	local make = premake.make
	local project = premake.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		make.cpp.allRules(cfg)
	end


--
-- Check the default, normal format of the rules.
--

	function suite.defaultRules()
		prepare()
		test.capture [[
all: $(TARGET) | $(TARGETDIR) $(OBJDIR) prebuild prelink
	@:
		]]
	end


--
-- Check rules for an OS X Cocoa application.
--

	function suite.osxWindowedAppRules()
		system "MacOSX"
		kind "WindowedApp"
		prepare()
		test.capture [[
all: $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist | $(TARGETDIR) $(OBJDIR) prebuild prelink
	@:

$(dir $(TARGETDIR))PkgInfo:
$(dir $(TARGETDIR))Info.plist:
		]]
	end
