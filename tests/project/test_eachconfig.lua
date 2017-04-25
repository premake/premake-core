--
-- tests/project/test_eachconfig.lua
-- Test the project object configuration iterator function.
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("project_eachconfig")


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		wks = workspace("MyWorkspace")
	end

	local function prepare(buildcfgs)
		project("MyProject")
		if buildcfgs then
			configurations ( buildcfgs )
		end
		prj = test.getproject(wks, 1)
		for cfg in p.project.eachconfig(prj) do
			_p(2,'%s:%s', cfg.buildcfg or "", cfg.platform or "")
		end
	end


--
-- If no configurations have been defined, the iterator
-- should not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsAndNoPlatforms()
		prepare()
		test.isemptycapture()
	end


--
-- If platforms have been defined, but no configurations, the
-- iterator should still not return any values.
--

	function suite.returnsNoValues_onNoConfigurationsButPlatforms()
		platforms { "x86", "x86_64" }
		prepare()
		test.isemptycapture()
	end


--
-- Configurations should be iterated in the order in which they
-- appear in the script.
--

	function suite.iteratesConfigsInOrder()
		configurations { "Debug", "Profile", "Release", "Deploy" }
		prepare()
		test.capture [[
		Debug:
		Profile:
		Release:
		Deploy:
		]]
	end


--
-- If platforms are supplied, they should be paired with build
-- configurations, with the order of both maintained.
--

	function suite.pairsConfigsAndPlatformsInOrder()
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		prepare()
		test.capture [[
		Debug:x86
		Debug:x86_64
		Release:x86
		Release:x86_64
		]]
	end


--
-- Test the mapping of a build configuration from workspace to project.
--

	function suite.mapsBuildCfg_toBuildCfg()
		configurations { "Debug", "Release" }
		configmap { ["Debug"] = "ProjectDebug" }
		prepare()
		test.capture [[
		ProjectDebug:
		Release:
		]]
	end


--
-- Test mapping a platform from workspace to project.
--

	function suite.mapsPlatform_toPlatform()
		configurations { "Debug", "Release" }
		platforms { "Win32" }
		configmap { ["Win32"] = "x86_64" }
		prepare()
		test.capture [[
		Debug:x86_64
		Release:x86_64
		]]
	end


--
-- Test mapping a build configuration to a build config/platform pair.
-- This will cause a second platform to appear in the project, alongside
-- the one defined by the workspace.
--

	function suite.mapsBuildCfg_toBuildCfgAndPlatform()
		configurations { "Debug", "Release" }
		platforms { "Win32" }
		configmap { ["Debug"] = { "ProjectDebug", "x86_64" } }
		prepare()
		test.capture [[
		ProjectDebug:x86_64
		ProjectDebug:Win32
		Release:x86_64
		Release:Win32
		]]
	end


--
-- Any duplicate configurations created by the mapping should be removed.
--

	function suite.removesDups_onConfigMapping()
		configurations { "Debug", "Development", "Release" }
		configmap { ["Development"] = "Debug" }
		prepare()
		test.capture [[
		Debug:
		Release:
		]]
	end


--
-- If there is overlap in the workspace and project configuration lists,
-- the ordering at the project level should be maintained to avoid
-- unnecessarily dirtying the project file.
--

	function suite.maintainsProjectOrdering_onWorkspaceOverlap()
		configurations { "Debug", "Release" }
		prepare { "Debug", "Development", "Profile", "Release" }
		test.capture [[
		Debug:
		Development:
		Profile:
		Release:
		]]
	end

