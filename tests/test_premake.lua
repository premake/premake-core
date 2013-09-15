--
-- tests/test_premake.lua
-- Automated test suite for the Premake support functions.
-- Copyright (c) 2008-2009 Jason Perkins and the Premake project
--


	T.premake = {}
	local suite = T.premake


--
-- Setup
--

	local sln, prj
	function suite.setup()
		sln = test.createsolution()
		location "MyLocation"
		prj = premake.solution.getproject(sln, 1)
	end


--
-- generate() tests
--

	function suite.generate_OpensCorrectFile()
		premake.generate(prj, ".prj", function () end)
		test.openedfile(path.join(os.getcwd(), "MyLocation/MyProject.prj"))
	end

	function T.premake.generate_ClosesFile()
		premake.generate(prj, ".prj", function () end)
		test.closedfile(true)
	end
