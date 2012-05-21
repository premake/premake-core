--
-- tests/oven/test_lists.lua
-- Test the Premake oven list handling.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.oven_lists = { }
	local suite = T.oven_lists
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- API values that are not set in any configuration should be initialized
-- with empty defaults (makes downstream usage easier).
--

	function suite.emptyDefaultsSet_forMissingApiValues()
		local cfg = oven.bake(sln)
		test.isequal(0, #cfg.defines)
	end


--
-- Values defined at the solution level should be included in configurations
-- built from the solution.
--

	function suite.solutionValuePresent_onSolutionConfig()
		defines "SOLUTION"
		local cfg = oven.bake(sln)
		test.isequal("SOLUTION", table.concat(cfg.defines))
	end


--
-- Values defined at the project level should be included in configurations
-- built from the project.
--

	function suite.projectValuePreset_onProjectConfig()
		prj = project "MyProject"
		defines "PROJECT"
		local cfg = oven.bake(prj, sln)
		test.isequal("PROJECT", table.concat(cfg.defines))
	end


--
-- Values defined at the solution level should also be present in 
-- configurations built from projects within that solution.
--

	function suite.solutionValuePresent_onProjectConfig()
		defines("SOLUTION")
		prj = project("MyProject")
		local cfg = oven.bake(prj, sln)
		test.isequal("SOLUTION", table.concat(cfg.defines))
	end


--
-- When a list value is present at both the solution and project
-- level, the values should be merged, with the solution values
-- coming first.
--

	function suite.solutionAndProjectValuesMerged_onProjectConfig()
		defines("SOLUTION")
		prj = project("MyProject")
		defines("PROJECT")
		local cfg = oven.bake(prj, sln)
		test.isequal("SOLUTION|PROJECT", table.concat(cfg.defines, "|"))
	end


--
-- A value specified in a block with more general terms should appear
-- in more specific configurations.
--

	function suite.valueFromGeneralConfigPreset_onMoreSpecificConfig()
		defines("SOLUTION")
		local cfg = oven.bake(sln, nil, {"Debug"})
		test.isequal("SOLUTION", table.concat(cfg.defines))
	end

	function suite.valueFromGeneralConfigPreset_onMoreSpecificConfig()
		configuration("Debug")
		defines("DEBUG")
		local cfg = oven.bake(sln, nil, {"Debug","Windows"})
		test.isequal("DEBUG", table.concat(cfg.defines))
	end


--
-- Values present in a specific configuration should only be included
-- if a matching filter term is present.
--

	function suite.configValueNotPresent_ifNoMatchingFilterTerm()
		configuration("Debug")
		defines("DEBUG")
		cfg = oven.bake(sln)
		test.isequal(0, #cfg.defines)
	end

	function suite.configValuePresent_ifMatchingFilterTerm()
		configuration("Debug")
		kind "SharedLib"
		cfg = oven.bake(sln, nil, {"Debug"})
		test.isequal("SharedLib", cfg.kind)
	end


--
-- When values for a field are present in solution and project configurations,
-- all should be copied, with the solution values first.
--

	function suite.solutionAndProjectAndConfigValuesMerged()
		defines("SOLUTION")
		configuration("Debug")
		defines("SLN_DEBUG")
		prj = project("MyProject")
		defines("PROJECT")
		configuration("Debug")
		defines("PRJ_DEBUG")
		cfg = oven.bake(prj	, sln, {"Debug"})
		test.isequal("SOLUTION|SLN_DEBUG|PROJECT|PRJ_DEBUG", table.concat(cfg.defines, "|"))
	end


--
-- Duplicate values should be removed from list values.
--

	function suite.removesDuplicateValues()
		defines { "SOLUTION", "DUPLICATE" }
		prj = project("MyProject")
		defines { "PROJECT", "DUPLICATE" }
		cfg = oven.bake(prj, sln, {"Debug"})
		test.isequal("SOLUTION|PROJECT|DUPLICATE", table.concat(cfg.defines, "|"))
	end
