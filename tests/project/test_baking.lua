--
-- tests/project/test_baking.lua
-- Test the Premake oven, which handles flattening of configurations.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_baking = { }
	local suite = T.project_baking
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
		local cfg = oven.bake(prj)
		test.isequal("PROJECT", table.concat(cfg.defines))
	end


--
-- Values defined at the solution level should also be present in 
-- configurations built from projects within that solution.
--

	function suite.solutionValuePresent_onProjectConfig()
		defines("SOLUTION")
		prj = project("MyProject")
		local cfg = oven.bake(prj)
		test.isequal("SOLUTION", table.concat(cfg.defines))
	end


--
-- When an array value is present at both the solution and project
-- level, the values should be merged, with the solution values
-- coming first.
--

	function suite.solutionAndProjectValuesMerged_onProjectConfig()
		defines("SOLUTION")
		prj = project("MyProject")
		defines("PROJECT")
		local cfg = oven.bake(prj)
		test.isequal("SOLUTION|PROJECT", table.concat(cfg.defines, "|"))
	end


--
-- A value specified in a block with more general terms should appear
-- in more specific configurations.
--

	function suite.valueFromGeneralConfigPreset_onMoreSpecificConfig()
		defines("SOLUTION")
		local cfg = oven.bake(sln, {"Debug"})
		test.isequal("SOLUTION", table.concat(cfg.defines))
	end

	function suite.valueFromGeneralConfigPreset_onMoreSpecificConfig()
		configuration("Debug")
		defines("DEBUG")
		local cfg = oven.bake(sln, {"Debug","Windows"})
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
		cfg = oven.bake(sln, {"Debug"})
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
		cfg = oven.bake(prj	, {"Debug"})
		test.isequal("SOLUTION|SLN_DEBUG|PROJECT|PRJ_DEBUG", table.concat(cfg.defines, "|"))
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


--
-- Duplicate values should be removed from list values.
--

	function suite.removesDuplicateValues()
		defines { "SOLUTION", "DUPLICATE" }
		prj = project("MyProject")
		defines { "PROJECT", "DUPLICATE" }
		cfg = oven.bake(prj, {"Debug"})
		test.isequal("SOLUTION|DUPLICATE|PROJECT", table.concat(cfg.defines, "|"))
	end


--
-- Multiple calls to key-value functions should be merged into a single key-value table.
-- I don't have any config-level key-value fields yet, so have to bake project instead.
--

	function suite.keyValuesAreMerged_onMultipleKeys()
		vpaths { ["Solution"] = "*.sln" }
		prj = project("MyProject")
		vpaths { ["Project"] = "*.prj" }
		cfg = oven.merge(oven.merge({}, sln), prj)
		test.isequal({"*.sln"}, cfg.vpaths["Solution"])
		test.isequal({"*.prj"}, cfg.vpaths["Project"])
	end

	
	function suite.keyValuesAreMerged_onMultipleValues()
		vpaths { ["Solution"] = "*.sln", ["Project"] = "*.prj" }
		prj = project("MyProject")
		vpaths { ["Project"] = "*.prjx" }
		cfg = oven.merge(oven.merge({}, sln), prj)
		test.isequal({"*.prj","*.prjx"}, cfg.vpaths["Project"])
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
		cfg = oven.bake(prj, {"Debug"})
		test.isequal("prj", cfg.buildrule.description)
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

		cfg = oven.merge({}, sln)
		cfg = oven.merge(cfg, prj)
		test.isequal({ "Release" }, cfg.configurations)
	end
