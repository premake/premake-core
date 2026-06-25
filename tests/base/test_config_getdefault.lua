--
-- tests/base/test_config_getdefault.lua
-- Unit tests for the config.getdefault() function.
-- Tests the priority order and fallback behavior for default configurations.
--

	local p = premake
	local suite = test.declare("config_getdefault")


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		wks = workspace("MyWorkspace")
		configurations { "Release", "Debug", "Profile" }
		prj = project("MyProject")
		kind "ConsoleApp"
	end


--
-- Verify project default behavior: returns first project configuration in
-- alphabetic order.
--

	function suite.returnsFirstAlphabetically_onProjectNoDefaults()
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
	end


--
-- Verify matching defaultconfiguration only
--

	function suite.matchesDefaultConfiguration_whenSpecified()
		defaultconfiguration "Release"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Release", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
	end


--
-- Verify matching defaultplatform only
--

	function suite.matchesDefaultPlatform_whenSpecified()
		platforms { "x86", "x64" }
		defaultplatform "x64"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
	end


--
-- Verify matching both defaultconfiguration and defaultplatform
-- Priority: both match > configuration match > platform match > first

	function suite.prefersBothMatching_overPartial()
		platforms { "x86", "x64" }
		defaultconfiguration "Profile"
		defaultplatform "x64"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Profile", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
	end


--
-- Verify that invalid defaultconfiguration falls back to first
--

	function suite.fallsBackToFirst_onInvalidConfiguration()
		defaultconfiguration "NonExistent"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
		test.stderr("defaultconfiguration 'NonExistent'")
	end


--
-- Verify that invalid defaultplatform falls back to first
--

	function suite.fallsBackToFirst_onInvalidPlatform()
		platforms { "x86", "x64" }
		defaultplatform "ARM"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
		test.stderr("defaultplatform 'ARM'")
	end


--
-- Verify case-insensitivity of defaultconfiguration matching
--

	function suite.caseInsensitive_forConfiguration()
		defaultconfiguration "RELEASE"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Release", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
	end


--
-- Verify case-insensitivity of defaultplatform matching
--

	function suite.caseInsensitive_forPlatform()
		platforms { "x86", "x64" }
		defaultplatform "X64"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
	end


--
-- Verify priority: when both defaultconfiguration is invalid but defaultplatform is valid,
-- return the defaultplatform match
--

	function suite.prefersValidPlatform_whenConfigInvalid()
		platforms { "x86", "x64" }
		defaultconfiguration "NonExistent"
		defaultplatform "x64"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
		test.stderr("defaultconfiguration 'NonExistent'")
	end


--
-- Verify priority: when defaultconfiguration is valid but defaultplatform is invalid,
-- return the defaultconfiguration match
--

	function suite.prefersValidConfiguration_whenPlatformInvalid()
		platforms { "x86", "x64" }
		defaultconfiguration "Release"
		defaultplatform "ARM"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Release", cfg.buildcfg)
		test.isequal("x64", cfg.platform)
		test.stderr("defaultplatform 'ARM'")
	end


--
-- Verify with many configurations that the correct one is chosen
--

	function suite.selectsCorrectConfig_withMany()
		configurations { "Debug", "Release", "Profile", "MinSize", "CustomDebug" }
		platforms { "x86", "x64", "ARM" }
		defaultconfiguration "Profile"
		defaultplatform "ARM"
		prj = test.getproject(wks, 1)
		local cfg = p.config.getdefault(prj)
		test.isequal("Profile", cfg.buildcfg)
		test.isequal("ARM", cfg.platform)
	end


--
-- Verify workspace default behavior: returns first workspace configuration in
-- alphabetic order.
--

	function suite.returnsFirstAlphabetically_onWorkspaceNoDefaults()
		local wks2 = workspace("WorkspaceForTest")
		configurations { "Release", "Debug", "Profile" }
		wks2 = test.getWorkspace(wks2)
		local cfg = p.config.getdefault(wks2)
		test.isequal("Debug", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
	end


--
-- Verify workspace level defaultconfiguration.
--

	function suite.matchesDefaultConfiguration_onWorkspace()
		local wks2 = workspace("WorkspaceForDefaultConfigurationTest")
		configurations { "Release", "Debug", "Profile" }
		defaultconfiguration "Release"
		wks2 = test.getWorkspace(wks2)
		local cfg = p.config.getdefault(wks2)
		test.isequal("Release", cfg.buildcfg)
		test.isequal(nil, cfg.platform)
	end
