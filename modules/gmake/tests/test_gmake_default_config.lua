--
-- modules/gmake/tests/test_gmake_default_config.lua
-- Validate generation of default configuration block for makefiles.
--

	local suite = test.declare("gmake_default_config")

	local p = premake
	local gmake = premake.modules.gmake


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		gmake.defaultconfig(prj)
	end


--
-- Verify the handling of the default setup: Debug and Release, no platforms.
--

	function suite.defaultsToFirstBuildCfg_onNoPlatforms()
		prepare()
		test.capture [[
ifndef config
  config=debug
endif
		]]
	end


--
-- Verify handling of defaultconfiguration.
--

	function suite.defaultsToSpecifiedConfiguration()
		defaultconfiguration "Release"
		prepare()
		test.capture [[
ifndef config
  config=release
endif
		]]
	end


--
-- Verify handling of defaultconfiguration and defaultplatform together.
--

	function suite.defaultsToSpecifiedConfigurationAndPlatform()
		platforms { "Win32", "Win64" }
		defaultconfiguration "Release"
		defaultplatform "Win64"
		prepare()
		test.capture [[
ifndef config
  config=release_win64
endif
		]]
	end


--
-- Verify handling of defaultplatform only (no defaultconfiguration).
--

	function suite.defaultsToSpecifiedPlatform_onNoPlatformDefault()
		platforms { "Win32", "Win64" }
		defaultplatform "Win64"
		prepare()
		test.capture [[
ifndef config
  config=debug_win64
endif
		]]
	end


--
-- Verify that invalid defaultconfiguration falls back to first config.
--

	function suite.fallsBackToFirstConfig_onInvalidConfiguration()
		defaultconfiguration "NonExistent"
		prepare()
		test.capture [[
ifndef config
  config=debug
endif
		]]
	end


--
-- Verify that invalid defaultplatform falls back to first platform.
--

	function suite.fallsBackToFirstPlatform_onInvalidPlatform()
		platforms { "Win32", "Win64" }
		defaultplatform "ARM"
		prepare()
		test.capture [[
ifndef config
  config=debug_win32
endif
		]]
	end


--
-- Verify case-insensitive matching for defaultconfiguration.
--

	function suite.caseInsensitive_forConfiguration()
		defaultconfiguration "RELEASE"
		prepare()
		test.capture [[
ifndef config
  config=release
endif
		]]
	end


--
-- Verify case-insensitive matching for defaultplatform.
--

	function suite.caseInsensitive_forPlatform()
		platforms { "Win32", "Win64" }
		defaultplatform "WIN64"
		prepare()
		test.capture [[
ifndef config
  config=debug_win64
endif
		]]
	end


--
-- Verify priority: valid defaultplatform with invalid defaultconfiguration.
--

	function suite.prefersValidPlatform_whenConfigInvalid()
		platforms { "Win32", "Win64" }
		defaultconfiguration "NonExistent"
		defaultplatform "Win64"
		prepare()
		test.capture [[
ifndef config
  config=debug_win64
endif
		]]
	end


--
-- Verify priority: valid defaultconfiguration with invalid defaultplatform.
--

	function suite.prefersValidConfiguration_whenPlatformInvalid()
		platforms { "Win32", "Win64" }
		defaultconfiguration "Release"
		defaultplatform "ARM"
		prepare()
		test.capture [[
ifndef config
  config=release_win32
endif
		]]
	end
