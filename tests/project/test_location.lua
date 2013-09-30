--
-- tests/project/test_location.lua
-- Test handling of the projects's location field.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("project_location")


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
	end


--
-- If no explicit location is set, the location should be set to the
-- directory containing the script which defined the project.
--

	function suite.usesScriptLocation_onNoLocation()
		prepare()
		test.isequal(os.getcwd(), prj.location)
	end


--
-- If an explicit location has been set, use it.
--

	function suite.usesLocation_onLocationSet()
		location "build"
		prepare()
		test.isequal(path.join(os.getcwd(), "build"), prj.location)
	end


--
-- If the solution sets a location, and the project does not, it should
-- inherit the value from the solution.
--

	function suite.inheritsSolutionLocation_onNoProjectLocation()
		solution ()
		location "build"
		prepare()
		test.isequal(path.join(os.getcwd(), "build"), prj.location)
	end
