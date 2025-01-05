--
-- test_gmake_target_rules.lua
-- Validate the makefile target building rules.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local suite = test.declare("gmake_target_rules")

	local p = premake
	local gmake = p.modules.gmake

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
		gmake.cpp.allRules(cfg)
	end


--
-- Check the default, normal format of the rules.
--

	function suite.defaultRules()
		prepare()
		test.capture [[
all: $(TARGET)
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
all: $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist
	@:

$(dir $(TARGETDIR))PkgInfo:
$(dir $(TARGETDIR))Info.plist:
		]]
	end
