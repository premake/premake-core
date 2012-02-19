--
-- tests/project/test_eachconfig.lua
-- Test the project object configuration iterator function.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_eachconfig = { }
	local suite = T.project_eachconfig


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end

	local function prepare()
		project("MyProject")
		prj = premake.solution.getproject_ng(sln, 1)
		for cfg in premake5.project.eachconfig(prj, field) do
			_p(2,'%s:%s', cfg.buildcfg or "", cfg.platform or "")
		end
	end


--
-- If no configurations have been defined, the iterator
-- should not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsAndNoPlatforms()
		prepare()
		test.isemptycapture()
	end


--
-- If platforms have been defined, but no configurations, the
-- iterator should still not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsButPlatforms()
		platforms { "x32", "x64" }
		prepare()
		test.isemptycapture()
	end


--
-- Configurations should be iterated in the order in which they
-- appear in the script.
--

	function suite.iteratesConfigsInOrder()
		configurations { "Debug", "Profile", "Release", "Deploy" }
		prepare()
		test.capture [[
		Debug:
		Profile:
		Release:
		Deploy:
		]]
	end


--
-- If platforms are supplied, they should be paired with build 
-- configurations, with the order of both maintained.
--

	function suite.pairsConfigsAndPlatformsInOrder()
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		prepare()
		test.capture [[
		Debug:x32
		Debug:x64
		Release:x32
		Release:x64
		]]
	end
