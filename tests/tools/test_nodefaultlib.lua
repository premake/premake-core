--
-- tests/tools/test_nodefaultlib.lua
-- Test the nodefaultlib API.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("test_nodefaultlib")
	local p = premake
	local msc = p.tools.msc


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end

	local function prepareRelease()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Release")
	end


--
-- Test that nodefaultlib "On" generates /Zl for compiler and /NODEFAULTLIB for linker
--

	function suite.nodefaultlibOn_cflags()
		nodefaultlib "On"
		prepare()
		test.contains("/Zl", msc.getcflags(cfg))
	end

	function suite.nodefaultlibOn_cxxflags()
		nodefaultlib "On"
		prepare()
		test.contains("/Zl", msc.getcxxflags(cfg))
	end

	function suite.nodefaultlibOn_ldflags()
		kind "ConsoleApp"
		nodefaultlib "On"
		prepare()
		test.contains("/NODEFAULTLIB", msc.getldflags(cfg))
	end


--
-- Test that Off does not generate flags
--

	function suite.nodefaultlibOff_cflags()
		nodefaultlib "Off"
		prepare()
		test.excludes("/Zl", msc.getcflags(cfg))
	end

	function suite.nodefaultlibOff_ldflags()
		kind "ConsoleApp"
		nodefaultlib "Off"
		prepare()
		test.excludes("/NODEFAULTLIB", msc.getldflags(cfg))
	end


--
-- Test deprecated flag still works
--

	function suite.deprecatedFlag_OmitDefaultLibrary_cflags()
		flags { "OmitDefaultLibrary" }
		prepare()
		test.contains("/Zl", msc.getcflags(cfg))
	end

	function suite.deprecatedFlag_OmitDefaultLibrary_ldflags()
		kind "ConsoleApp"
		flags { "OmitDefaultLibrary" }
		prepare()
		test.contains("/NODEFAULTLIB", msc.getldflags(cfg))
	end
