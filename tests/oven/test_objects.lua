--
-- tests/oven/test_objects.lua
-- Test Premake oven handling of objects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_objects = { }
	local suite = T.oven_objects
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- Object values should be merged into baked results.
--

	function suite.objectValuesAreMerged()
		buildrule { description="test" }
		cfg = oven.bake(sln)
		test.isequal("test", cfg.buildrule.description)
	end

	function suite.objectValueOverwritten_onMultipleValues()
		buildrule { description="sln" }
		prj = project("MyProject")
		buildrule { description="prj" }
		cfg = oven.bake(prj, sln, {"Debug"})
		test.isequal("prj", cfg.buildrule.description)
	end
