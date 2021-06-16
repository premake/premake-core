local premake = require('premake')
local State = require('state')
local Type = require('type')

local Root = Type.declare('Root', State)


---
-- Instantiate a new root state configuration helper.
--
-- @param criteria
--    Key-value criteria to apply to the new state. Used to evaluate the `when()`
--    elements in the user's project script.
-- @returns
--    A new root state helper instance.
---

function Root.new(criteria)
	return Type.assign(Root, premake.newState(criteria or _EMPTY))
end


---
-- Retrieve the workspaces contained by this root state.
--
-- @param createCallback
--    A function of with signature `(rootState, workspaceName)` which will be called for
--    each workspace name found in the state. Return a new `dom.Workspace` to represent
--    the workspace, or `nil` to ignore it.
-- @returns
--    A table of workspaces, keyed by both integer index and name.
---

function Root.fetchWorkspaces(self, createCallback)
	local workspaces = {}

	local names = self.workspaces
	for i = 1, #names do
		local name = names[i]
		local wks = createCallback(self, name)
		workspaces[i] = wks
		workspaces[name] = wks
	end

	return workspaces
end


return Root
