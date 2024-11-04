--
-- tests/actions/make/cpp/test_target_rules.lua
-- Validate the makefile target building rules.
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_cpp_target_rules")
	local make = p.make
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
		make.cppAllRules(cfg)
	end


--
-- Check the default, normal format of the rules.
--

	function suite.defaultRules()
		prepare()
		test.capture [[
all: prebuild prelink $(TARGET)
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
all: prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist
	@:

$(dir $(TARGETDIR))PkgInfo:
$(dir $(TARGETDIR))Info.plist:
		]]
	end
