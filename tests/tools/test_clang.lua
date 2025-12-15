--
-- tests/test_clang.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
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
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isequal("clang", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++", clang.gettoolname(cfg, "cxx"))
		test.isequal("ar", clang.gettoolname(cfg, "ar"))
		test.isequal("windres", clang.gettoolname(cfg, "rc"))
	end

	function suite.tools_onLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.isequal("clang", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++", clang.gettoolname(cfg, "cxx"))
		test.isequal("llvm-ar", clang.gettoolname(cfg, "ar"))
		test.isequal("windres", clang.gettoolname(cfg, "rc"))
	end

	function suite.tools_onFastLinkTimeOptimizationViaAPI()
		linktimeoptimization "Fast"
		prepare()
		test.isequal("clang", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++", clang.gettoolname(cfg, "cxx"))
		test.isequal("llvm-ar", clang.gettoolname(cfg, "ar"))
		test.isequal("windres", clang.gettoolname(cfg, "rc"))
	end

	function suite.tools_forVersion()
		toolset "clang-16"
		prepare()
		test.isequal("clang-16", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++-16", clang.gettoolname(cfg, "cxx"))
		test.isequal("ar-16", clang.gettoolname(cfg, "ar"))
		test.isequal("windres-16", clang.gettoolname(cfg, "rc"))
	end

	function suite.tools_forVersion_onLinkTimeOptimizationViaAPI()
		toolset "clang-16"
		linktimeoptimization "On"
		prepare()
		test.isequal("clang-16", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++-16", clang.gettoolname(cfg, "cxx"))
		test.isequal("llvm-ar-16", clang.gettoolname(cfg, "ar"))
		test.isequal("windres-16", clang.gettoolname(cfg, "rc"))
	end

	function suite.tools_forVersion_onFastLinkTimeOptimizationViaAPI()
		toolset "clang-16"
		linktimeoptimization "Fast"
		prepare()
		test.isequal("clang-16", clang.gettoolname(cfg, "cc"))
		test.isequal("clang++-16", clang.gettoolname(cfg, "cxx"))
		test.isequal("llvm-ar-16", clang.gettoolname(cfg, "ar"))
		test.isequal("windres-16", clang.gettoolname(cfg, "rc"))
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
-- Check tvOS deployment target flags
--

function suite.cflags_tvos_systemversion()
	system "tvOS"
	systemversion "12.1"
	prepare()
	test.contains({ "-mappletvos-version-min=12.1" }, clang.getcflags(cfg))
end

function suite.cxxflags_tvos_systemversion()
	system "tvOS"
	systemversion "5.0"
	prepare()
	test.contains({ "-mappletvos-version-min=5.0" }, clang.getcxxflags(cfg))
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
-- Check handling of linker flag.
--

	function suite.ldflags_linker_lld()
		linker "LLD"
		prepare()
		test.contains("-fuse-ld=lld", clang.getldflags(cfg))
	end

--
-- Check handling of link time optimization flag.
--

	function suite.cflags_onLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.contains("-flto", clang.getcflags(cfg))
	end

	function suite.cflags_onFastLinkTimeOptimizationViaAPI()
		linktimeoptimization "Fast"
		prepare()
		test.contains("-flto=thin", clang.getcflags(cfg))
	end

	function suite.ldflags_onLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.contains("-flto", clang.getldflags(cfg))
	end

	function suite.ldflags_onFastLinkTimeOptimizationViaAPI()
		linktimeoptimization "Fast"
		prepare()
		test.contains("-flto=thin", clang.getldflags(cfg))
	end

--
-- Check the translation of CXXFLAGS.
--

	function suite.onSanitizeAddress()
		sanitize { "Address" }
		prepare()
		test.contains({ "-fsanitize=address" }, clang.getcxxflags(cfg))
		test.contains({ "-fsanitize=address" }, clang.getcflags(cfg))
		test.contains({ "-fsanitize=address" }, clang.getldflags(cfg))
	end

	function suite.cxxflags_onSanitizeFuzzer()
		sanitize { "Fuzzer" }
		prepare()
		test.contains({ "-fsanitize=fuzzer" }, clang.getcxxflags(cfg))
		test.contains({ "-fsanitize=fuzzer" }, clang.getcflags(cfg))
		test.contains({ "-fsanitize=fuzzer" }, clang.getldflags(cfg))
	end

	function suite.cxxflags_onSanitizeThread()
		sanitize { "Thread" }
		prepare()
		test.contains({ "-fsanitize=thread" }, clang.getcxxflags(cfg))
		test.contains({ "-fsanitize=thread" }, clang.getcflags(cfg))
		test.contains({ "-fsanitize=thread" }, clang.getldflags(cfg))
	end

	-- UBSan
	function suite.cxxflags_onSanitizeUndefined()
		sanitize { "UndefinedBehavior" }
		prepare()
		test.contains({ "-fsanitize=undefined" }, clang.getcxxflags(cfg))
		test.contains({ "-fsanitize=undefined" }, clang.getcflags(cfg))
		test.contains({ "-fsanitize=undefined" }, clang.getldflags(cfg))
	end

--
-- Test the optimization flags.
--
	function suite.onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.contains("-Og", clang.getcflags(cfg))
		test.contains("-Og", clang.getcxxflags(cfg))
	end

	function suite.onOptimizeSize()
		optimize "Size"
		prepare()
		test.contains("-Os", clang.getcflags(cfg))
		test.contains("-Os", clang.getcxxflags(cfg))
	end

	function suite.onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.contains("-O3", clang.getcflags(cfg))
		test.contains("-O3", clang.getcxxflags(cfg))
	end

	function suite.onOptimizeOff()
		optimize "Off"
		prepare()
		test.contains("-O0", clang.getcflags(cfg))
		test.contains("-O0", clang.getcxxflags(cfg))
	end

	function suite.onOptimizeOn()
		optimize "On"
		prepare()
		test.contains("-O2", clang.getcflags(cfg))
		test.contains("-O2", clang.getcxxflags(cfg))
	end

	function suite.onOptimizeFull()
		optimize "Full"
		prepare()
		test.contains("-O3", clang.getcflags(cfg))
		test.contains("-O3", clang.getcxxflags(cfg))
	end

--
-- Test profiling flag
--

	function suite.flags_onProfileOff()
		profile "Off"

		prepare()
		test.excludes({ "-pg" }, clang.getcflags(cfg))
		test.excludes({ "-pg" }, clang.getcxxflags(cfg))
		test.excludes({ "-pg" }, clang.getldflags(cfg))
	end

	function suite.flags_onProfileOn()
		profile "On"

		prepare()
		test.contains({ "-pg" }, clang.getcflags(cfg))
		test.contains({ "-pg" }, clang.getcxxflags(cfg))
		test.contains({ "-pg" }, clang.getldflags(cfg))
	end

--
-- Make sure system or architecture flags are added properly.
--

	function suite.cflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, clang.getcflags(cfg))
	end

	function suite.ldflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, clang.getldflags(cfg))
	end

	function suite.cflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, clang.getcflags(cfg))
	end

	function suite.ldflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, clang.getldflags(cfg))
	end

	function suite.cflags_macosx_onX86()
		system "macosx"
		architecture "x86"
		prepare()
		test.excludes({ "-m32" }, clang.getcflags(cfg))
		test.contains({ "-arch i386" }, clang.getcflags(cfg))
	end

	function suite.ldflags_macosx_onX86()
		system "macosx"
		architecture "x86"
		prepare()
		test.excludes({ "-m32" }, clang.getldflags(cfg))
		test.contains({ "-arch i386" }, clang.getldflags(cfg))
	end

	function suite.cflags_macosx_onX86_64()
		system "macosx"
		architecture "x86_64"
		prepare()
		test.excludes({ "-m64" }, clang.getcflags(cfg))
		test.contains({ "-arch x86_64" }, clang.getcflags(cfg))
	end

	function suite.ldflags_macosx_onX86_64()
		system "macosx"
		architecture "x86_64"
		prepare()
		test.excludes({ "-m64" }, clang.getldflags(cfg))
		test.contains({ "-arch x86_64" }, clang.getldflags(cfg))
	end

	function suite.cflags_macosx_onarm64()
		system "macosx"
		architecture "arm64"
		prepare()
		test.contains({ "-arch arm64" }, clang.getcflags(cfg))
	end

	function suite.ldflags_macosx_onarm64()
		system "macosx"
		architecture "arm64"
		prepare()
		test.contains({ "-arch arm64" }, clang.getldflags(cfg))
	end
