--
-- tests/project/test_hasconfig.lua
-- Test the project object hasconfig() existence test function.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.project_hasconfig = { }
	local suite = T.project_hasconfig


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
	end


--
-- Should return true for configurations from the solution.
--

	function suite.returnsTrue_onSolutionConfig()
		prepare()
		test.istrue(premake5.project.hasconfig(prj, "Debug"))
	end


--
-- Should return true for configurations from the project.
--

	function suite.returnsTrue_onSolutionConfig()
		configurations { "Custom" }
		prepare()
		test.istrue(premake5.project.hasconfig(prj, "Custom"))
	end


--
-- Should return false for configurations specified in other projects.
--

	function suite.returnsTrue_onSolutionConfig()
		project("MyProject2")
		configurations { "Custom" }
		prepare()
		test.isfalse(premake5.project.hasconfig(prj, "Custom"))
	end


--
-- Should return false if configuration is removed by the project.
--

	function suite.returnsFalse_onConfigRemoved()
		removeconfigurations { "Debug" }
		prepare()
		test.isfalse(premake5.project.hasconfig(prj, "Debug"))
	end

