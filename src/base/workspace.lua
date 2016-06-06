---
-- workspace.lua
-- Work with the list of workspaces loaded from the script.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake
	p.workspace = p.api.container("workspace", p.global)

	local workspace = p.workspace


---
-- Switch this container's name from "solution" to "workspace"
--
-- We changed these names on 30 Jul 2015. While it might be nice to leave
-- `solution()` around for Visual Studio folks and everyone still used to the
-- old system, it would be good to eventually deprecate and remove all of
-- the other, more internal uses of "solution" and "sln". Probably including
-- all uses of container class aliases, since we probably aren't going to
-- need those again (right?).
---

	p.solution = workspace
	workspace.alias = "solution"

	p.alias(_G, "workspace", "solution")
	p.alias(_G, "externalworkspace", "externalsolution")



---
-- Create a new workspace container instance.
---

	function workspace.new(name)
		local wks = p.container.new(workspace, name)
		return wks
	end



--
-- Iterate over the configurations of a workspace.
--
-- @return
--    A configuration iteration function.
--

	function workspace.eachconfig(self)
		self = p.oven.bakeWorkspace(self)

		local i = 0
		return function()
			i = i + 1
			if i > #self.configs then
				return nil
			else
				return self.configs[i]
			end
		end
	end


--
-- Iterate over the projects of a workspace.
--
-- @return
--    An iterator function, returning project configurations.
--

	function workspace.eachproject(self)
		local i = 0
		return function ()
			i = i + 1
			if i <= #self.projects then
				return p.workspace.getproject(self, i)
			end
		end
	end


--
-- Locate a project by name, case insensitive.
--
-- @param name
--    The name of the projec to find.
-- @return
--    The project object, or nil if a matching project could not be found.
--

	function workspace.findproject(self, name)
		name = name:lower()
		for _, prj in ipairs(self.projects) do
			if name == prj.name:lower() then
				return prj
			end
		end
		return nil
	end


--
-- Retrieve the tree of project groups.
--
-- @return
--    The tree of project groups defined for the workspace.
--

	function workspace.grouptree(self)
		-- check for a previously cached tree
		if self.grouptree then
			return self.grouptree
		end

		-- build the tree of groups

		local tr = p.tree.new()
		for prj in workspace.eachproject(self) do
			local prjpath = path.join(prj.group, prj.name)
			local node = p.tree.add(tr, prjpath)
			node.project = prj
		end

		-- assign UUIDs to each node in the tree
		p.tree.traverse(tr, {
			onbranch = function(node)
				node.uuid = os.uuid("group:" .. node.path)
			end
		})

		self.grouptree = tr
		return tr
	end


--
-- Retrieve the project configuration at a particular index.
--
-- @param idx
--    An index into the array of projects.
-- @return
--    The project configuration at the given index.
--

	function workspace.getproject(self, idx)
		self = p.oven.bakeWorkspace(self)
		return self.projects[idx]
	end



---
-- Determines if the workspace contains a project that meets certain criteria.
--
-- @param func
--    A test function. Receives a project as its only argument and returns a
--    boolean indicating whether it meets to matching criteria.
-- @return
--    True if the test function returned true.
---

	function workspace.hasProject(self, func)
		return p.container.hasChild(self, p.project, func)
	end


--
-- Return the relative path from the solution to the specified file.
--
-- @param self
--    The workspace object to query.
-- @param filename
--    The file path, or an array of file paths, to convert.
-- @return
--    The relative path, or array of paths, from the workspace to the file.
--

	function workspace.getrelative(self, filename)
		if type(filename) == "table" then
			local result = {}
			for i, name in ipairs(filename) do
				if name and #name > 0 then
					table.insert(result, workspace.getrelative(self, name))
				end
			end
			return result
		else
			if filename then
				return path.getrelative(self.location, filename)
			end
		end
	end
