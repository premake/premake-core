--
-- tests/workspace/test_eachconfig.lua
-- Automated test suite for the workspace-level configuration iterator.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("workspace_eachconfig")

	local p = premake


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		wks = workspace("MyWorkspace")
	end

	local function prepare()
		p.w("-")
		for cfg in p.workspace.eachconfig(wks) do
			p.w("%s:%s", cfg.buildcfg or "", cfg.platform or "")
		end
		p.w("-")
	end


--
-- All configurations listed at the workspace level should be enumerated.
--

	function suite.listsBuildConfigurations_onWorkspaceLevel()
		configurations { "Debug", "Release" }
		project("MyProject")
		prepare()
		test.capture [[
-
Debug:
Release:
-
		]]
	end


--
-- Iteration order should be build configurations, then platforms.
--

	function suite.listsInOrder_onBuildConfigsAndPlatforms()
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		project("MyProject")
		prepare()
		test.capture [[
-
Debug:x86
Debug:x86_64
Release:x86
Release:x86_64
-
		]]
	end


--
-- Configurations listed at the project level should *not* be included
-- in the workspace-level lists.
--

	function suite.excludesProjectLevelConfigs()
		configurations { "Debug", "Release" }
		project ("MyProject")
		configurations { "PrjDebug", "PrjRelease" }
		platforms { "x86", "x86_64" }
		prepare()
		test.capture [[
-
Debug:
Release:
-
		]]
	end
