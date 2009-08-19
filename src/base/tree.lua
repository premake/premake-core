--
-- tree.lua
-- Functions for working with the source code tree.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	premake.tree = { }


--
-- Create a new tree.
--
-- @param n
--    The name of the tree, applied to the root node (optional).
--

	function premake.tree.new(n)
		local t = {
			name = n,
			children = { }
		}
		return t
	end


--
-- Add a new node to the tree, or returns the current node if it already exists.
--
-- @param tr
--    The tree to contain the new node.
-- @param p
--    The path of the new node.
-- @returns
--    The new tree node.
--

	function premake.tree.add(tr, p)
		-- locate the parent node (or keep the root)
		local dir = path.getdirectory(p)
		if dir ~= "." then
			tr = premake.tree.add(tr, dir)
		end
		
		-- add it if it doesn't exist already
		local name = path.getname(p)
		local child = tr.children[name]
		if not child then
			child = premake.tree.new(name)
			child.path = p
			premake.tree.insert(tr, child)
		end
		return child
	end


--
-- Insert one tree into another.
--
-- @param parent
--    The parent tree, to contain the child.
-- @param child
--    The child tree, to be inserted.
--

	function premake.tree.insert(parent, child)
		table.insert(parent.children, child)
		if child.name then
			parent.children[child.name] = child
		end
		child.parent = parent
	end


--
-- Traverse a tree.
--
-- @param t
--    The tree to traverse.
-- @param fn
--    A collection of callback functions, which may contain:
--
--    onnode(node, depth)   - called on each node encountered
--    onleaf(node, depth)   - called only on leaf nodes
--    onbranch(node, depth) - called only on branch nodes
--
-- @param includeroot
--    True to include the root node in the traversal, otherwise it will be skipped.
--

	function premake.tree.traverse(t, fn, includeroot)

		local donode, dochildren
		donode = function(node, fn, depth)
			if fn.onnode then fn.onnode(node, depth) end
			if #node.children > 0 then
				if fn.onbranch then fn.onbranch(node, depth) end
				dochildren(node, fn, depth + 1)
			else
				if fn.onleaf then fn.onleaf(node, depth) end
			end
		end
		
		dochildren = function(parent, fn, depth)
			for _, node in ipairs(parent.children) do
				donode(node, fn, depth)
			end
		end
		
		if includeroot then
			donode(t, fn, 0)
		else
			dochildren(t, fn, 0)
		end
	end
