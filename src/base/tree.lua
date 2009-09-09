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
		
		-- add it if it doesn't exist already (but skip over .. directories, which
		-- are never shown in any of the tools)
		local name = path.getname(p)
		if name ~= ".." then
			local child = tr.children[name]
			if not child then
				child = premake.tree.new(name)
				child.path = p
				premake.tree.insert(tr, child)
			end
			return child
		else
			return tr
		end
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
		return child
	end


--
-- Gets the node's relative path from it's parent. If the parent does not have
-- a path set (it is the root or other container node) returns the full node path.
--
-- @param node
--    The node to query.
--

	function premake.tree.getlocalpath(node)
		if node.parent.path then
			return node.name
		else
			return node.path
		end
	end


--
-- Remove a node from a tree.
--
-- @param node
--    The node to remove.
--

	function premake.tree.remove(node)
		local children = node.parent.children
		for i = 1, #children do
			if children[i] == node then
				table.remove(children, i)
			end
		end
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
			if node.isremoved then return end
			if fn.onnode then fn.onnode(node, depth) end
			if #node.children > 0 then
				if fn.onbranch then fn.onbranch(node, depth) end
				dochildren(node, fn, depth + 1)
			else
				if fn.onleaf then fn.onleaf(node, depth) end
			end
		end
		
		dochildren = function(parent, fn, depth)
			-- this goofy iterator allows nodes to be removed during the traversal
			local i = 1
			while i <= #parent.children do
				local node = parent.children[i]
				donode(node, fn, depth)
				if node == parent.children[i] then
					i = i + 1
				end
			end
		end
		
		if includeroot then
			donode(t, fn, 0)
		else
			dochildren(t, fn, 0)
		end
	end
