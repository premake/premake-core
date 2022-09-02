--
-- tests/test_clang.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("tools_clang")

	local clang = p.tools.clang
	local project = p.project


--
-- Setup/teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks, prj = test.createWorkspace()
		system "Linux"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check Mac OS X deployment target flags
--

	function suite.cflags_macosx_systemversion()
		system "MacOSX"
		systemversion "10.9"
		prepare()
		test.contains({ "-mmacosx-version-min=10.9" }, clang.getcflags(cfg))
	end

	function suite.cxxflags_macosx_systemversion()
		system "MacOSX"
		systemversion "10.9"
		prepare()
		test.contains({ "-mmacosx-version-min=10.9" }, clang.getcxxflags(cfg))
	end

	function suite.cxxflags_macosx_systemversion_unspecified()
		system "MacOSX"
		prepare()
		test.excludes({ "-mmacosx-version-min=10.9" }, clang.getcxxflags(cfg))
	end

--
-- Check iOS deployment target flags
--

	function suite.cflags_ios_systemversion()
		system "iOS"
		systemversion "12.1"
		prepare()
		test.contains({ "-miphoneos-version-min=12.1" }, clang.getcflags(cfg))
	end

	function suite.cxxflags_ios_systemversion()
		system "iOS"
		systemversion "5.0"
		prepare()
		test.contains({ "-miphoneos-version-min=5.0" }, clang.getcxxflags(cfg))
	end

--
-- Check handling of openmp.
--

	function suite.cflags_onOpenmpOn()
		openmp "On"
		prepare()
		test.contains("-fopenmp", clang.getcflags(cfg))
	end

	function suite.cflags_onOpenmpOff()
		openmp "Off"
		prepare()
		test.excludes("-fopenmp", clang.getcflags(cfg))
	end

--
-- Check the translation of CXXFLAGS.
--

function suite.cxxflags_onSanitizeFuzzer()
	sanitize { "Fuzzer" }
	prepare()
	test.contains({ "-fsanitize=fuzzer" }, clang.getcxxflags(cfg))
end
