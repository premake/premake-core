--
-- tests/oven/test_basics.lua
-- Test the Premake oven, which handles flattening of configurations.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_basics = { }
	local suite = T.oven_basics
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- When a solution is baked, a reference to that solution should be
-- placed in the resulting configuration.
--

	function suite.solutionSet_whenCalledOnSolution()
		local cfg = oven.bake(sln)
		test.istrue(sln == cfg.solution)
	end


--
-- When a project is baked, a reference to that project should be
-- placed in the resulting configuration.
--

	function suite.solutionSet_whenCalledOnSolution()
		prj = project("MyProject")
		local cfg = oven.bake(prj)
		test.istrue(prj == cfg.project)
	end


--
-- Test pulling "project global" values, which are associated with
-- all configurations in the project.
--

	function suite.callPullProjectLevelConfig()
		prj = project("MyProject")
		files { "hello.cpp" }
		cfg = oven.bake(prj, {}, "files")
		test.isequal("hello.cpp", cfg.files[1]:sub(-9))
	end


--
-- The keywords field should NOT be included in the configuration objects
-- returned by the backing process.
--

	function suite.noKeywordsInBakingResults()
		configuration("Debug")
		defines("DEBUG")
		cfg = oven.bake(sln)
		test.isnil(cfg.keywords)
	end


--
-- Requests for a single field should return just that value.
--

	function suite.fieldValueReturned_onFilterFieldPresent()
		configuration("Debug")
		kind "SharedLib"
		cfg = oven.bake(sln, {"Debug"}, "kind")
		test.isequal("SharedLib", cfg.kind)
	end

	function suite.otherFieldsNotReturned_onFilterFieldPresent()
		configuration("Debug")
		kind("SharedLib")
		defines("DEBUG")
		cfg = oven.bake(sln, {"Debug"}, "kind")
		test.isnil(cfg.defines)
	end
