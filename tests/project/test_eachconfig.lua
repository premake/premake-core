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
