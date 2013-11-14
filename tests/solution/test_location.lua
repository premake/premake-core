--
-- tests/solution/test_location.lua
-- Test handling of the solution's location field.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("solution_location")


--
-- Setup and teardown
--

	local sln

	function suite.setup()
		sln = solution("MySolution")
	end

	local function prepare()
		sln = premake.oven.bakeSolution(sln)
	end


--
-- If no explicit location is set, the location should be set to the
-- directory containing the script which defined the solution.
--

	function suite.usesScriptLocation_onNoLocation()
		prepare()
		test.isequal(os.getcwd(), sln.location)
	end


--
-- If an explicit location has been set, use it.
--

	function suite.usesLocation_onLocationSet()
		location "build"
		prepare()
		test.isequal(path.join(os.getcwd(), "build"), sln.location)
	end
