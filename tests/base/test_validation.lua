--
-- tests/base/test_validation.lua
-- Verify the project information sanity checking.
-- Copyright (c) 2013-20124 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_validation")


--
-- Setup
--

	local function verify()
		ok, err = pcall(premake.validate)
		return ok and not test.stderr()
	end


--
-- Validate should pass if the minimum requirements are met.
--

	function suite.passes_onSane()
		solution "MySolution"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"

		test.istrue(pcall(premake.validate))
		test.stderr()
	end


--
-- Fail if no configurations are present on the solution.
--

	function suite.fails_onNoSolutionConfigs()
		solution "MySolution"
		project "MyProject"
			kind "ConsoleApp"
			language "C++"

		test.isfalse(pcall(premake.validate))
	end


--
-- Fail on duplicate project UUIDs.
--

	function suite.fails_onDuplicateProjectIDs()
		solution "MySolution"
			configurations { "Debug", "Release" }
			kind "ConsoleApp"
			language "C++"
		project "MyProject1"
			uuid "D4110D7D-FB18-4A1C-A75B-CA432F4FE770"
		project "MyProject2"
			uuid "D4110D7D-FB18-4A1C-A75B-CA432F4FE770"

		test.isfalse(pcall(premake.validate))
	end


--
-- Fail if no kind is set on the configuration.
--

	function suite.fails_onNoConfigKind()
		solution "MySolution"
			configurations { "Debug", "Release" }
		project "MyProject"
			language "C++"

		test.isfalse(pcall(premake.validate))
	end


--
-- Warn if a configuration value is set in the wrong scope.
--

	function suite.warns_onSolutionStringField_inConfig()
		solution "MySolution"
			configurations { "Debug", "Release" }
		filter "Debug"
			startproject "MyProject"
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		premake.validate()
		test.stderr("'startproject' on config")
	end

	function suite.warns_onProjectStringField_inConfig()
		solution "MySolution"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		filter "Debug"
			location "MyProject"
		premake.validate()
		test.stderr("'location' on config")
	end

	function suite.warns_onProjectKeyedField_inConfig()
		solution "MySolution"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		filter "Debug"
			vpaths { ["Headers"] = "**.h" }
		premake.validate()
		test.stderr("'vpaths' on config")
	end

	function suite.warns_onProjectListField_inConfig()
		solution "MySolution"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		filter "Debug"
			configurations "Deployment"
		premake.validate()
		test.stderr("'configurations' on config")
	end
