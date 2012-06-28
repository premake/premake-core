--
-- tests/actions/make/cpp/test_target_rules.lua
-- Validate the makefile target building rules.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.make_cpp_target_rules = { }
	local suite = T.make_cpp_target_rules
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		local cfg = project.getconfig(prj, "Debug")
		cpp.targetrules(cfg)
	end


--
-- Check the default, normal format of the rules.
--

	function suite.defaultRules()
		prepare()
		test.capture [[
all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)
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
all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist
	@:

$(dir $(TARGETDIR))PkgInfo:
$(dir $(TARGETDIR))Info.plist:
  		]]
	end
