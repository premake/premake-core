--
-- tests/project/test_eachconfig.lua
-- Test the project object configuration iterator function.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.project_eachconfig = { }
	local suite = T.project_eachconfig
	local premake = premake5


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end

	local function prepare()
		prj = project("MyProject")
	end

	local function collect(fn)
		prepare()
		local result = { }
		for cfg in premake.project.eachconfig(prj) do
			table.insert(result, fn(cfg))
		end
		return result
	end


--
-- The return value should be a function.
--

	function suite.returnsIteratorFunction()
		prepare()
		local it = premake.project.eachconfig(prj)
		test.isequal("function", type(it))
	end


--
-- If no configurations have been defined, the iterator
-- should not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsAndNoPlatforms()
		prepare()
		local it = premake.project.eachconfig(prj)
		test.isnil(it())
	end


--
-- If platforms have been defined, but no configurations, the
-- iterator should still not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsButPlatforms()
		platforms { "x32", "x64" }
		prepare()
		local it = premake.project.eachconfig(prj)
		test.isnil(it())
	end


--
-- Configurations should be iterated in the order in which they
-- appear in the script.
--

	function suite.iteratesConfigsInOrder()
		configurations { "Debug", "Profile", "Release", "Deploy" }
		local r = collect(function(cfg) return cfg.buildcfg end)
		test.isequal("Debug|Profile|Release|Deploy", table.concat(r, "|"))
	end


--
-- If platforms are supplied, they should be paired with build 
-- configurations, with the order of both maintained.
--

	function suite.pairsConfigsAndPlatformsInOrder()
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		local r = collect(function(cfg) return (cfg.buildcfg .. "+" .. cfg.platform) end)
		test.isequal("Debug+x32|Debug+x64|Release+x32|Release+x64", table.concat(r, "|"))
	end
