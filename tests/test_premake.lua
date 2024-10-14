--
-- tests/test_premake.lua
-- Automated test suite for the Premake support functions.
-- Copyright (c) 2008-2015 Jess Perkins and the Premake project
--


	local suite = test.declare("premake")

	local p = premake


--
-- Setup
--

	local wks, prj
	function suite.setup()
		wks = test.createWorkspace()
		location "MyLocation"
		prj = p.workspace.getproject(wks, 1)
	end


--
-- generate() tests
--

	function suite.generate_OpensCorrectFile()
		p.generate(prj, ".prj", function () end)
		test.openedfile(path.join(os.getcwd(), "MyLocation/MyProject.prj"))
	end

	function suite.generate_ClosesFile()
		p.generate(prj, ".prj", function () end)
		test.closedfile(true)
	end
