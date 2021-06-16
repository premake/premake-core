local premake = require('premake')
local Store = require('store')
local State = require('state')

local StateRemoveTests = test.declare('StateRemoveTests', 'state')


local _global

function StateRemoveTests.setup()
	_global = State.new(premake.store())
end


---
-- Value is added and removed at the same scope.
---

function StateRemoveTests.globalAdds_globalRemoves()
	defines { 'A', 'B', 'C' }
	removeDefines 'B'

	test.isEqual({ 'A', 'C' }, _global.defines)
end


---
-- Value is defined by the workspace, then removed by one of several projects.
--
-- In most toolset project formats, it is difficult if not impossible to remove a
-- value once it has been set. To avoid that situation, all configuration provided
-- by Premake to the export modules must be additive only; any values that need to
-- be removed must be handled by the query code.
--
-- In this case, projects are contained by a workspace, and inherit all of its
-- values. If we write the to-be-removed value to the workspace, it would need to
-- be removed in the project, which breaks the whole additive-only rule. Instead,
-- the query must remove it from the *workspace*, and then add it back to all of
-- the projects where it *wasn't* removed.
--
-- In theory, and every nomimal use case I can think of, this should get the same end
-- result at build-time. Hypothetically, there could be a case where it is important
-- for that value to be set at the higher level scope. Will have to solve that case
-- if and when it comes up.
---

function StateRemoveTests.workspaceAdds_projectRemoves_removesFromWorkspace()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	test.isEqual({ 'A', 'C' }, wks.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_removesFromTarget()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' })
	test.isEqual({}, prj.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_removesFromTarget_inherit()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):withInheritance()
	test.isEqual({ 'A', 'C' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_addsToSiblings()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' })
	test.isEqual({ 'B' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_addsToSiblings_inherit()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):withInheritance()
	test.isEqual({ 'A', 'B', 'C' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_removesFromTarget_include()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }
	end)

	when({'projects:Project2'}, function ()
		removeDefines 'B'
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):fromScopes(_global)
	test.isEqual({}, prj.defines)
end


function StateRemoveTests.workspaceAdds_projectRemoves_addsToSiblings_include()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }
	end)

	when({'projects:Project2'}, function ()
		removeDefines 'B'
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):fromScopes(_global)
	test.isEqual({ 'B' }, prj.defines)
end


---
-- Verify more permutations of the same pattern for completeness.
---

function StateRemoveTests.globalAdds_projectRemoves_removesFromGlobal()
	defines { 'A', 'B', 'C' }

	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	test.isEqual({ 'A', 'C' }, _global.defines)
end


function StateRemoveTests.globalAdds_projectRemoves_ignoresWorkspace()
	defines { 'A', 'B', 'C' }

	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	test.isEqual({}, wks.defines)
end


function StateRemoveTests.globalAdds_projectRemoves_ignoresWorkspace_inherit()
	defines { 'A', 'B', 'C' }

	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	test.isEqual({ 'A', 'C' }, wks.defines)
end


function StateRemoveTests.globaleAdds_projectRemoves_removesFromTarget()
	defines { 'A', 'B', 'C' }
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' })
	test.isEqual({}, prj.defines)
end


function StateRemoveTests.globalAdds_projectRemoves_removesFromTarget_inherit()
	defines { 'A', 'B', 'C' }
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project2' }):withInheritance()
	test.isEqual({ 'A', 'C' }, prj.defines)
end


function StateRemoveTests.globalAdds_projectRemoves_addsToSiblings()
	defines { 'A', 'B', 'C' }
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' })
	test.isEqual({ 'B' }, prj.defines)
end


function StateRemoveTests.globalAdds_projectRemoves_addsToSiblings_inheerit()
	defines { 'A', 'B', 'C' }
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		when({'projects:Project2'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project1' }):withInheritance()
	test.isEqual({ 'A', 'B', 'C' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_removesFromWorkspace()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	test.isEqual({ 'A', 'C' }, wks.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_removesFromWksCfg()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local cfg = wks:selectAny({ configurations='Debug', platforms='macOS' }):withInheritance()
	test.isEqual({ 'A', 'C' }, cfg.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_removesFromTargetProj()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):withInheritance()
	test.isEqual({ 'A', 'C' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_ignoresSiblingProjs()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' }):withInheritance()
	test.isEqual({ 'A', 'B', 'C' }, prj.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_removesFromTarget()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' })
	local cfg = prj:selectAny({ configurations='Debug', platforms='macOS' })
	test.isEqual({}, cfg.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_removesFromTarget_inherit()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):withInheritance()
	local cfg = prj:selectAny({ configurations='Debug', platforms='macOS' }):withInheritance()
	test.isEqual({ 'A', 'C' }, cfg.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_addsToSiblings()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' })
	local cfg = prj:selectAny({ configurations='Release', platforms='macOS' })
	test.isEqual({ 'B' }, cfg.defines)
end


function StateRemoveTests.workspaceAdds_projConfigRemoves_addsToSiblings_inherit()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			when({'configurations:Debug'}, function ()
				removeDefines 'B'
			end)
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):withInheritance()
	local cfg = prj:selectAny({ configurations='Release', platforms='macOS' }):withInheritance()
	test.isEqual({ 'A', 'B', 'C' }, cfg.defines)
end


function StateRemoveTests.workspaceAdds_globProjConfigRemoves_removesFromTarget()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		configurations { 'Debug', 'Release' }
		platforms { 'macOS', 'iOS' }
		defines { 'A', 'B', 'C' }
	end)

	when({'projects:Project2'}, function ()
		when({'configurations:Debug'}, function ()
			removeDefines 'B'
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project2' }):fromScopes(_global)
	local cfg = prj:selectAny({ configurations='Debug', platforms='macOS' })
	test.isEqual({}, cfg.defines)
end


---
-- When adding values back into a configuration, should only add values that would have
-- actually been removed at the outer scopes.
---

function StateRemoveTests.workspaceAdds_projectRemoves_ignoresUnsetValues()
	workspace('Workspace1', function ()
		projects { 'Project1', 'Project2', 'Project3' }
		defines { 'A', 'B', 'C' }

		when({'projects:Project2'}, function ()
			removeDefines { 'B', 'D' }
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' })
	local prj = wks:select({ projects = 'Project1' })
	test.isEqual({ 'B' }, prj.defines)
end


---
-- Found this one while testing removeFiles(); could probably be folded into one of the
-- tests above but I don't want to mess with what's working. If a value is both added
-- and removed "above" my target scope, I shouldn't see any of the removed values at all.
---

function StateRemoveTests.projectsAdds_projectRemoves_doesNotAddToConfig()
	workspace('Workspace1', function ()
		configurations { 'Debug', 'Release' }
		project('Project1', function ()
			defines { 'A' }
			removeDefines { 'A' }
		end)
	end)

	local wks = _global:select({ workspaces = 'Workspace1' }):withInheritance()
	local prj = wks:select({ projects = 'Project1' }):withInheritance()
	local cfg = prj:select({ configurations = 'Debug' })

	test.isEqual({}, cfg.defines)
end
