---
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
---

	local p = premake
	p.solution = p.api.container("solution", p.global)

	local solution = p.solution
	local tree = p.tree



---
-- Create a new solution container instance.
---

	function solution.new(name)
		local sln = p.container.new(solution, name)
		return sln
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
-- Return the relative path from the solution to the specified file.
--
-- @param prj
--    The solution object to query.
-- @param filename
--    The file path, or an array of file paths, to convert.
-- @return
--    The relative path, or array of paths, from the solution to the file.
--

	function solution.getrelative(sln, filename)
		if type(filename) == "table" then
			local result = {}
			for i, name in ipairs(filename) do
				result[i] = solution.getrelative(sln, name)
			end
			return result
		else
			if filename then
				return path.getrelative(sln.location, filename)
			end
		end
	end
