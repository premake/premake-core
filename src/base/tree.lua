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
-- @param t
--    The tree to contain the new node.
-- @param name
--    The name of the new node, as a file path
-- @returns
--    The new tree node.
--

	function premake.tree.add(t, name)
		local dir = path.getdirectory(name)
		if dir ~= "." then
			t = premake.tree.add(t, dir)
			name = path.getname(name)
		end
		
		local child = t.children[name]
		if not child then
			child = premake.tree.new(name)
			premake.tree.insert(t, child)
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
	end


--
-- Traverse a tree.
--
-- @param t
--    The tree to traverse.
-- @param fn
--    A collection of callback functions, which may contain:
--
--    onnode(node, depth) - called on each node encountered
--
--    onleafnode(node, depth) - called only on leaf nodes
--

	function premake.tree.traverse(t, fn)
		local function traversal(t, fn, depth)
			for _, node in ipairs(t.children) do
				if fn.onnode then fn.onnode(node, depth) end
				if #node.children > 0 then
					traversal(node, fn, depth + 1)
				else
					if fn.onleafnode then fn.onleafnode(node, depth) end
				end
			end
		end
		traversal(t, fn, 0)
	end
