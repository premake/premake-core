--
-- tests/actions/make/test_config_maps.lua
-- Validate handling of configuration maps in makefiles.
-- Copyright (c) 2012 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_config_maps")
	local make = p.makelegacy


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		make.configmap(wks)
	end


--
-- If no map is present, the configurations should pass through
-- to the projects unchanged.
--

	function suite.passesThroughConfigs_onNoMap()
		prepare()
		test.capture [[
ifeq ($(config),debug)
  MyProject_config = debug
endif
ifeq ($(config),release)
  MyProject_config = release
endif
		]]
	end


--
-- If a map is present, the configuration change should be applied.
--

	function suite.passesThroughConfigs_onMap()
		configmap { Debug = "Development" }
		prepare()
		test.capture [[
ifeq ($(config),debug)
  MyProject_config = development
endif
ifeq ($(config),release)
  MyProject_config = release
endif
		]]
	end


--
-- If a configuration is not included in a particular project,
-- no mapping should be created.
--

	function suite.passesThroughConfigs_onNoMapRemovedConfiguration()
		removeconfigurations { "Debug" }
		prepare()
		test.capture [[
ifeq ($(config),debug)
endif
ifeq ($(config),release)
  MyProject_config = release
endif
		]]
	end
