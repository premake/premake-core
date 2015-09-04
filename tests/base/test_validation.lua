--
-- tests/base/test_validation.lua
-- Verify the project information sanity checking.
-- Copyright (c) 2013-20124 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_validation")

	local p = premake


--
-- Setup
--

	local function validate()
		return pcall(function() p.container.validate(p.api.rootContainer()) end)
	end


--
-- Validate should pass if the minimum requirements are met.
--

	function suite.passes_onSane()
		workspace("MyWorkspace")
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		test.istrue(validate())
	end


--
-- Fail if no configurations are present on the workspace.
--

	function suite.fails_onNoWorkspaceConfigs()
		workspace "MyWorkspace"
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		test.isfalse(validate())
	end


--
-- Fail on duplicate project UUIDs.
--

	function suite.fails_onDuplicateProjectIDs()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
			kind "ConsoleApp"
			language "C++"
		project "MyProject1"
			uuid "D4110D7D-FB18-4A1C-A75B-CA432F4FE770"
		project "MyProject2"
			uuid "D4110D7D-FB18-4A1C-A75B-CA432F4FE770"
		test.isfalse(validate())
	end


--
-- Fail if no kind is set on the configuration.
--

	function suite.fails_onNoConfigKind()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
		project "MyProject"
			language "C++"
		test.isfalse(validate())
	end


--
-- Warn if a configuration value is set in the wrong scope.
--

	function suite.warns_onWorkspaceStringField_inConfig()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
		filter "Debug"
			startproject "MyProject"
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		validate()
		test.stderr("'startproject' on config")
	end

	function suite.warns_onProjectStringField_inConfig()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		filter "Debug"
			location "MyProject"
		validate()
		test.stderr("'location' on config")
	end

	function suite.warns_onProjectListField_inConfig()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
		project "MyProject"
			kind "ConsoleApp"
			language "C++"
		filter "Debug"
			configurations "Deployment"
		validate()
		test.stderr("'configurations' on config")
	end


--
-- If a rule is specified for inclusion, it must have been defined.
--

	function suite.fails_onNoSuchRule()
		workspace "MyWorkspace"
			configurations { "Debug", "Release" }
		project "MyProject"
			rules { "NoSuchRule" }
		test.isfalse(validate())
	end

