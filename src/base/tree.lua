--
-- tree.lua
-- Functions for working with the source code tree.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	premake.tree = { }
	local tree = premake.tree


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
		-- Special case "." refers to the current node
		if p == "." then
			return tr
		end
		
		-- Look for the immediate parent for this new node, creating it if necessary.
		-- Recurses to create as much of the tree as necessary.
		local parentnode = tree.add(tr, path.getdirectory(p))

		-- Another special case, ".." refers to the parent node and doesn't create anything
		local childname = path.getname(p)
		if childname == ".." then
			return parentnode
		end
		
		-- Create the child if necessary. If two children with the same name appear
		-- at the same level, make sure they have the same path to prevent conflicts
		-- i.e. ../Common and ../../Common can both appear at the top of the tree
		-- yet they have different paths (Bug #3016050)
		local childnode = parentnode.children[childname]
		if not childnode or childnode.path ~= p then
			childnode = tree.insert(parentnode, tree.new(childname))
			childnode.path = p
		end
		
		return childnode
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
		node.children = {}
	end


--
-- Sort the nodes of a tree in-place.
--
-- @param tr
--    The tree to sort.
--

	function premake.tree.sort(tr)
		tree.traverse(tr, {
			onnode = function(node)
				table.sort(node.children, function(a,b)
					return a.name < b.name
				end)
			end
		}, true)
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
			if node.isremoved then 
				return 
			end
			if fn.onnode then 
				fn.onnode(node, depth) 
			end
			if #node.children > 0 then
				if fn.onbranch then 
					fn.onbranch(node, depth) 
				end
				dochildren(node, fn, depth + 1)
			else
				if fn.onleaf then 
					fn.onleaf(node, depth) 
				end
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
