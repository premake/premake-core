---
-- Test queries against scope hierarchies.
---

local premake = require('premake')
local State = require('state')


local StateSelectTests = test.declare('StateSelectTests', 'state')

local _global

function StateSelectTests.setup()
	defines 'GLOB'

	configurations { 'Debug', 'Release' }
	platforms { 'macOS', 'iOS' }

	when({ 'configurations:Debug' }, function ()
		defines 'GLOB_DEBUG'
	end)

	when({ 'platforms:macOS' }, function ()
		defines 'GLOB_MAC'
	end)

	when({ 'configurations:Debug', 'platforms:macOS' }, function ()
		defines 'GLOB_DEBUG_MAC'
	end)

	project('Project1', function ()
		defines 'GLOB_PRJ1'
		when({ 'configurations:Debug' }, function ()
			defines 'GLOB_PRJ1_DEBUG'
		end)
	end)

	workspace('Workspace1', function ()
		defines 'WKS1'

		when({ 'configurations:Debug' }, function ()
			defines 'WKS1_DEBUG'
		end)

		when({ 'platforms:macOS' }, function ()
			defines 'WKS1_MAC'
		end)

		when({ 'configurations:Debug', 'platforms:macOS' }, function ()
			defines 'WKS1_DEBUG_MAC'
		end)

		project('Project1', function ()
			defines 'WKS1_PRJ1'
			when({ 'configurations:Debug' }, function ()
				defines 'WKS1_PRJ1_DEBUG'
			end)
		end)
	end)

	workspace('Workspace2', function ()
		configurations { 'Debug', 'Release' }
		defines 'WKS2'

		when({ 'configurations:Debug' }, function ()
			defines 'WKS2_DEBUG'
		end)

		project('Project1', function ()
			defines 'WKS2_PRJ1'
			when({ 'configurations:Debug' }, function ()
				defines 'WKS2_PRJ1_DEBUG'
			end)
		end)
	end)

	_global = State.new(premake.store())
end


---
-- Imagine a toolset which supports a global settings file which can be included
-- into multiple workspaces. We'd want to write all of the top level general settings,
-- and only the top level settings, to this file.
--
-- The state object returned from new() represents this global configuration scope.
---

function StateSelectTests.select_global()
	test.isEqual({ 'GLOB' }, _global.defines)
end


---
-- If this global settings file also stored build configurations, we'd need to pull
-- in the top-level configurations and platforms blocks.
---

function StateSelectTests.select_config_fromGlobal()
	local cfg = _global:select({ configurations = 'Debug' })
	test.isEqual({ 'GLOB_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromGlobal()
	local cfg = _global:selectAny({ configurations = 'Debug', platforms = 'macOS' })
	test.isEqual({ 'GLOB_DEBUG', 'GLOB_MAC', 'GLOB_DEBUG_MAC'  }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromGlobal()
	local cfg = _global:select({ configurations = 'Debug', platforms = 'macOS' })
	test.isEqual({ 'GLOB_DEBUG_MAC'  }, cfg.defines)
end


---
-- If the global settings file did not support storing general settings, but rather
-- required everything to be contained by a build configuration, then we'd need to pull
-- the general configuration into the build configurations via inheritance.
---

function StateSelectTests.select_config_fromGlobal_inherit()
	local cfg = _global:select({ configurations = 'Debug' }):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromGlobal_inherit()
	local cfg = _global:selectAny({ configurations = 'Debug', platforms = 'macOS' }):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_DEBUG', 'GLOB_MAC', 'GLOB_DEBUG_MAC'  }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromGlobal_inherit()
	local cfg = _global:select({ configurations = 'Debug', platforms = 'macOS' }):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_DEBUG_MAC'  }, cfg.defines)
end


---
-- Now for workspaces. If there is a global settings file capturing all of the top level
-- settings, then workspaces should only contain settings specific to them and exclude
-- all top level configuration.
---

function StateSelectTests.select_workspace_fromGlobal()
	local wks = _global:select({ workspaces = 'Workspace1' })
	test.isEqual({ 'WKS1' }, wks.defines)
end


---
-- If there is no global settings file to capture the top level settings, then those must
-- be pulled into the workspace.
---

function StateSelectTests.select_workspace_fromGlobal_inherit()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	test.isEqual({ 'GLOB', 'WKS1' }, wks.defines)
end


---
-- If the global settings file captures the top level build configuration settings,
-- then the workspace build configurations should contain only per-workspace settings.
---

function StateSelectTests.select_config_fromWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug' })
	test.isEqual({ 'WKS1_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:selectAny({ configurations = 'Debug', platforms='macOS' })
	test.isEqual({ 'WKS1_DEBUG', 'WKS1_MAC', 'WKS1_DEBUG_MAC' }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug', platforms='macOS' })
	test.isEqual({ 'WKS1_DEBUG_MAC' }, cfg.defines)
end


---
-- Let's start getting combinatorial. There is a global settings file handling the top level
-- settings, which includes build configurations. The workspace does *not* support writing
-- general settings, and requires everything to be contained within a build configuration.
-- So: general workspace settings must be pulled into the workspace build configurations, but
-- global settings excluded.
---

function StateSelectTests.select_config_fromWorkspace_inherit()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug' }):withInheritance()
	test.isEqual({ 'WKS1', 'WKS1_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromWorkspace_inherit()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:selectAny({ configurations = 'Debug', platforms='macOS' }):withInheritance()
	test.isEqual({ 'WKS1', 'WKS1_DEBUG', 'WKS1_MAC', 'WKS1_DEBUG_MAC' }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromWorkspace_inherit()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug', platforms='macOS' }):withInheritance()
	test.isEqual({ 'WKS1', 'WKS1_DEBUG_MAC' }, cfg.defines)
end


---
-- There is no global settings file. The workspace can store general settings. Workspace
-- configurations need to exclude general settings no inheritance, but do need to include
-- configuration blocks defined outside of the target workspace.
---

function StateSelectTests.select_config_fromWorkspaceAndGlobal()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug' }):fromScopes(_global)
	test.isEqual({ 'GLOB_DEBUG', 'WKS1_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromWorkspaceAndGlobal()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:selectAny({ configurations = 'Debug', platforms='macOS' }):fromScopes(_global)
	test.isEqual({ 'GLOB_DEBUG', 'GLOB_MAC', 'GLOB_DEBUG_MAC', 'WKS1_DEBUG', 'WKS1_MAC', 'WKS1_DEBUG_MAC' }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromWorkspaceAndGlobal()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug', platforms='macOS' }):fromScopes(_global)
	test.isEqual({ 'GLOB_DEBUG_MAC', 'WKS1_DEBUG_MAC' }, cfg.defines)
end


---
-- Continue. There is no global settings file, and the workspace can *not* store
-- general settings. So: workspace build configurations are required to aggregrate
-- all of those values, pulling in build configuration blocks from the workspace
-- and global scopes, as well as inheriting general settings from both.
---

function StateSelectTests.select_config_fromWorkspaceAndGlobal_inheritBoth()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local cfg = wks:select({ configurations = 'Debug' }):fromScopes(_global):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_DEBUG', 'WKS1', 'WKS1_DEBUG' }, cfg.defines)
end


---
-- There *is* a global settings file, but it can only store general settings and not
-- build configurations. The workspace can only store build configurations and not
-- general settings. So: workspace build configurations must pull in build configuration
-- blocks from both the workspace and global levels, and inherit general settings
-- from the workspace but not the global scopes.
---

function StateSelectTests.select_config_fromWorkspaceAndGlobal_inheritWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:select({ configurations = 'Debug' }):fromScopes(_global):withInheritance()
	test.isEqual({ 'GLOB_DEBUG', 'WKS1', 'WKS1_DEBUG' }, cfg.defines)
end


---
-- There is a global settings file, but it can only store *build configurations* and
-- not general settings. Workspace can also only store build configurations and not
-- general settings. So: workspace configurations should only pull configuration blocks
-- from the workspace scope, but general settings from both workspace and global scopes.
---

function StateSelectTests.select_config_fromWorkspace_inheritWorkspaceAndGlobal()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local cfg = wks:select({ configurations = 'Debug' }):withInheritance()
	test.isEqual({ 'GLOB', 'WKS1', 'WKS1_DEBUG' }, cfg.defines)
end


---
-- On to projects. If the workspace is handling the top level settings, then projects
-- should only pull configuration specific to them. Projects must always include the
-- global scope in order to capture blocks specified outside of the target workspace;
-- I haven't managed to think up a way to avoid that.
---

function StateSelectTests.select_project_fromWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	test.isEqual({ 'GLOB_PRJ1', 'WKS1_PRJ1' }, prj.defines)
end

function StateSelectTests.select_project_fromWorkspace_workspaceInherits()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	test.isEqual({ 'GLOB_PRJ1', 'WKS1_PRJ1' }, prj.defines)
end


---
-- If the workspace does not handle the top level settings, or if the target toolset
-- doesn't support workspaces, projects must inherit both workspace and global scopes
-- to capture those values.
---

function StateSelectTests.select_project_fromWorkspace_inheritBoth()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_PRJ1', 'WKS1', 'WKS1_PRJ1' }, prj.defines)
end


---
-- Unlikely, but: if there is a global settings file covering the top level general
-- settings, but the workspace doesn't not include its own general settings, then the
-- project would need to pull in the workspace settings but not the global settings.
---

function StateSelectTests.select_project_fromWorkspace_inheritWorkspace()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global):withInheritance()
	test.isEqual({ 'GLOB_PRJ1', 'WKS1', 'WKS1_PRJ1' }, prj.defines)
end


---
-- The workspace handles general settings and build configurations. The project handles
-- general settings. So: project configurations should pull only the settings for that
-- specific project/build configuration pair and exclude anything more general.
---

function StateSelectTests.select_config_fromProject()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	local cfg = prj:select({ configurations = 'Debug' })
	test.isEqual({ 'GLOB_PRJ1_DEBUG', 'WKS1_PRJ1_DEBUG' }, cfg.defines)
end


---
-- The workspace handles general settings but not build configurations. The project
-- handles general settings. So: project configurations should pull in global, workspace,
-- and project level build configuration settings, while excluding the general settings
-- which were handled by the project.
---

function StateSelectTests.select_config_fromAll()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	local cfg = prj:select({ configurations = 'Debug' }):fromScopes(wks, _global)
	test.isEqual({ 'GLOB_DEBUG', 'GLOB_PRJ1_DEBUG', 'WKS1_DEBUG', 'WKS1_PRJ1_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configOrPlatform_fromAll()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	local cfg = prj:selectAny({ configurations = 'Debug', platforms='macOS' }):fromScopes(wks, _global)
	test.isEqual({ 'GLOB_DEBUG', 'GLOB_MAC', 'GLOB_DEBUG_MAC', 'GLOB_PRJ1_DEBUG', 'WKS1_DEBUG', 'WKS1_MAC', 'WKS1_DEBUG_MAC', 'WKS1_PRJ1_DEBUG' }, cfg.defines)
end

function StateSelectTests.select_configAndPlatform_fromAll()
	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	local cfg = prj:select({ configurations = 'Debug', platforms='macOS' }):fromScopes(wks, _global)
	test.isEqual({ 'GLOB_DEBUG_MAC', 'WKS1_DEBUG_MAC' }, cfg.defines)
end


---
-- The toolset does not support workspaces. The project does not handle general settings. So:
-- all settings must be pulled into the project build configurations.
---

function StateSelectTests.select_config_fromAll_inherit()
	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global):withInheritance()
	local cfg = prj:select({ configurations = 'Debug' }):fromScopes(wks, _global):withInheritance()
	test.isEqual({ 'GLOB', 'GLOB_DEBUG', 'GLOB_PRJ1', 'GLOB_PRJ1_DEBUG', 'WKS1', 'WKS1_DEBUG', 'WKS1_PRJ1', 'WKS1_PRJ1_DEBUG' }, cfg.defines)
end


---
-- The scope values specified at state creation should not be overwritten by values
-- returned by the query.
---

function StateSelectTests.select_config_fromGlobal_inherit_preservesScope()
	_LOG_PREMAKE_QUERIES = true
	local cfg = _global:select({ configurations = 'Debug' }):withInheritance()
	test.isEqual({ 'Debug' }, cfg.configurations)
end
