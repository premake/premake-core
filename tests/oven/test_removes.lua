--
-- tests/oven/test_removes.lua
-- Test the Premake oven ability to remove values from lists.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_removes = { }
	local suite = T.oven_removes
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- Check removing a value with an exact match.
--

	function suite.remove_onExactValueMatch()
		flags { "Symbols", "Optimize", "NoRTTI" }
		removeflags "Optimize"
		cfg = oven.bake(sln)
		test.isequal("Symbols|NoRTTI", table.concat(cfg.flags, "|"))
	end

	function suite.remove_onMultipleValues()
		flags { "Symbols", "NoExceptions", "Optimize", "NoRTTI" }
		removeflags { "NoExceptions", "NoRTTI" }
		cfg = oven.bake(sln)
		test.isequal("Symbols|Optimize", table.concat(cfg.flags, "|"))
	end


--
-- Remove should also accept wildcards.
--

	function suite.remove_onWildcard()
		defines { "WIN32", "WIN64", "LINUX", "MACOSX" }
		removedefines { "WIN*" }
		cfg = oven.bake(sln)
		test.isequal("LINUX|MACOSX", table.concat(cfg.defines, "|"))
	end

--
-- Remove should removed both indexed and keyed values.
--

	function suite.remove_onExactValueMatch()
		flags { "Symbols", "Optimize", "NoRTTI" }
		removeflags "Optimize"
		cfg = oven.bake(sln)
		test.isnil(cfg.flags.Optimize)
	end

--
-- Remove should also work with file paths.
--

	function suite.remove_onFileField()
		files { "hello.c", "goodbye.c" }
		removefiles { "goodbye.c" }
		cfg = oven.bake(sln)
		test.isequal(path.join(os.getcwd(), "hello.c"), table.concat(cfg.files))
	end

--
-- Remove should work on container-level fields too.
--

	function suite.remove_onContainerField()
		configurations { "Debug", "Release" }
		local prj = project "MyProject"
		removeconfigurations { "Debug" }
		cfg = oven.bake(prj)
		test.isequal({ "Release" }, cfg.configurations)
	end
