--
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	premake.solution = {}
	local solution = premake.solution

	local p = premake
	local tree = p.tree



---
-- Register a new container class to represent solutions.
---

	local _slnClass = p.api.container {
		name = "solution",
	}

	p.api.container {
		name = "group",
		parent = "solution",
	}



--
-- Add a new project to the solution.
--
-- @param sln
--    The solution to contain the project.
-- @param prj
--    The new project object.
--

	function solution.addproject(sln, prj)
		-- add keyed by array index AND name
		table.insert(sln.projects, prj)
		sln.projects[prj.name] = prj
	end


--
-- Iterate over the collection of solutions in a session.
--
-- @returns
--    An iterator function.
--

	function solution.each()
		local root = p.api.rootContainer()

		local i = 0
		return function ()
			i = i + 1
			if i <= #root.solutions then
				return root.solutions[i]
			end
		end
	end


--
-- Iterate over the configurations of a solution.
--
-- @param sln
--    The solution to query.
-- @return
--    A configuration iteration function.
--

	function solution.eachconfig(sln)
		sln = premake.oven.bakeSolution(sln)

		local i = 0
		return function()
			i = i + 1
			if i > #sln.configs then
				return nil
			else
				return sln.configs[i]
			end
		end
	end


--
-- Iterate over the projects of a solution (next-gen).
--
-- @param sln
--    The solution.
-- @return
--    An iterator function, returning project configurations.
--

	function solution.eachproject(sln)
		local i = 0
		return function ()
			i = i + 1
			if i <= #sln.projects then
				return premake.solution.getproject(sln, i)
			end
		end
	end


--
-- Locate a project by name, case insensitive.
--
-- @param sln
--    The solution to query.
-- @param name
--    The name of the projec to find.
-- @return
--    The project object, or nil if a matching project could not be found.
--

	function solution.findproject(sln, name)
		name = name:lower()
		for _, prj in ipairs(sln.projects) do
			if name == prj.name:lower() then
				return prj
			end
		end
		return nil
	end


--
-- Retrieve a solution by name or index.
--
-- @param key
--    The solution key, either a string name or integer index.
-- @returns
--    The solution with the provided key.
--

	function solution.get(key)
		local root = p.api.rootContainer()
		if root.solutions then
			return root.solutions[key]
		end
	end



--
-- Retrieve the tree of project groups.
--
-- @param sln
--    The solution to query.
-- @return
--    The tree of project groups defined for the solution.
--

	function solution.grouptree(sln)
		-- check for a previously cached tree
		if sln.grouptree then
			return sln.grouptree
		end

		-- build the tree of groups

		local tr = tree.new()
		for prj in solution.eachproject(sln) do
			local prjpath = path.join(prj.group, prj.name)
			local node = tree.add(tr, prjpath)
			node.project = prj
		end

		-- assign UUIDs to each node in the tree
		tree.traverse(tr, {
			onnode = function(node)
				node.uuid = os.uuid(node.path)
			end
		})

		sln.grouptree = tr
		return tr
	end


--
-- Retrieve the project configuration at a particular index.
--
-- @param sln
--    The solution.
-- @param idx
--    An index into the array of projects.
-- @return
--    The project configuration at the given index.
--

	function solution.getproject(sln, idx)
		sln = premake.oven.bakeSolution(sln)
		return sln.projects[idx]
	end


--
-- Checks to see if any projects contained by a solution use
-- a C or C++ as their language.
--
-- @param sln
--    The solution to query.
-- @return
--    True if at least one project in the solution uses C or C++.
--

	function solution.hascppproject(sln)
		for prj in solution.eachproject(sln) do
			if p.project.iscpp(prj) then
				return true
			end
		end
		return false
	end


--
-- Checks to see if any projects contained by a solution use
-- a .NET language.
--
-- @param sln
--    The solution to query.
-- @return
--    True if at least one project in the solution uses a
--    .NET language
--

	function solution.hasdotnetproject(sln)
		for prj in solution.eachproject(sln) do
			if p.project.isdotnet(prj) then
				return true
			end
		end
		return false
	end


