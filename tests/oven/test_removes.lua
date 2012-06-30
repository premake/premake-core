--
-- tests/oven/test_removes.lua
-- Test the Premake oven ability to remove values from lists.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_removes = { }
	local suite = T.oven_removes
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = premake5.project.getconfig(prj, "Debug")
	end



--
-- Check removing a value with an exact match.
--

	function suite.remove_onExactValueMatch()
		flags { "Symbols", "Optimize", "NoRTTI" }
		removeflags "Optimize"
		prepare()
		test.isequal({ "Symbols", "NoRTTI" }, cfg.flags)
	end

	function suite.remove_onMultipleValues()
		flags { "Symbols", "NoExceptions", "Optimize", "NoRTTI" }
		removeflags { "NoExceptions", "NoRTTI" }
		prepare()
		test.isequal({ "Symbols", "Optimize" }, cfg.flags)
	end


--
-- Remove should also accept wildcards.
--

	function suite.remove_onWildcard()
		defines { "WIN32", "WIN64", "LINUX", "MACOSX" }
		removedefines { "WIN*" }
		prepare()
		test.isequal({ "LINUX", "MACOSX" }, cfg.defines)
	end

--
-- Remove should removed both indexed and keyed values.
--

	function suite.remove_onExactValueMatch()
		flags { "Symbols", "Optimize", "NoRTTI" }
		removeflags "Optimize"
		prepare()
		test.isnil(cfg.flags.Optimize)
	end

--
-- Remove should also work with file paths.
--

	function suite.remove_onFileField()
		files { "hello.c", "goodbye.c" }
		removefiles { "goodbye.c" }
		prepare()
		test.isequal({ path.join(os.getcwd(), "hello.c") }, cfg.files)
	end

	function suite.remove_onExcludesWildcard()
		files { "hello.c", "goodbye.c" }
		excludes { "goodbye.*" }
		prepare()
		test.isequal({ path.join(os.getcwd(), "hello.c") }, cfg.files)
	end


--
-- Remove should work on container-level fields too.
--

	function suite.remove_onContainerField()
		removeconfigurations { "Release" }
		prepare()
		test.isequal({ "Debug" }, cfg.project.configurations)
	end
