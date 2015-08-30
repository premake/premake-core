--
-- tests/solution/test_location.lua
-- Test handling of the solution's location field.
-- Copyright (c) 2013-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("solution_location")


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		wks = solution("MySolution")
	end

	local function prepare()
		wks = test.getsolution(wks)
	end


--
-- If no explicit location is set, the location should be set to the
-- directory containing the script which defined the solution.
--

	function suite.usesScriptLocation_onNoLocation()
		prepare()
		test.isequal(os.getcwd(), wks.location)
	end


--
-- If an explicit location has been set, use it.
--

	function suite.usesLocation_onLocationSet()
		location "build"
		prepare()
		test.isequal(path.join(os.getcwd(), "build"), wks.location)
	end
