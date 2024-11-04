--
-- tree.lua
-- Functions for working with the source code tree.
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
--

	local p = premake
	p.tree = {}
	local tree = p.tree


--
-- Create a new tree.
--
-- @param n
--    The name of the tree, applied to the root node (optional).
--

	function tree.new(n)
		local t = {
			name = n,
			children = {}
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
-- @param extraFields
--    A table containing key-value pairs to be added to any new nodes.
-- @returns
--    The new tree node.
--

	function tree.add(tr, p, extraFields)
		-- Special case "." refers to the current node
		if p == "." or p == "/" then
			return tr
		end

		-- Look for the immediate parent for this new node, creating it if necessary.
		-- Recurses to create as much of the tree as necessary.
		local parentnode = tree.add(tr, path.getdirectory(p), extraFields)

		-- Create the child if necessary
		local childname = path.getname(p)
		local childnode = parentnode.children[childname]
		if not childnode or childnode.path ~= p then
			childnode = tree.insert(parentnode, tree.new(childname))
			childnode.path = p
			if extraFields then
				for k,v in pairs(extraFields) do
					childnode[k] = v
				end
			end
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

	function tree.insert(parent, child)
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

	function tree.getlocalpath(node)
		if node.parent.path then
			return node.name
		elseif node.cfg then
			return node.cfg.name
		else
			return node.path
		end
	end


--
-- Determines if the tree contains any branch nodes, or only leaves.
--
-- @param tr
--    The root node of the tree to query.
-- @return
--    True if a node below the root contains children, false otherwise.
--

	function tree.hasbranches(tr)
		local n = #tr.children
		if n > 0 then
			for i = 1, n do
				if #tr.children[i].children > 0 then
					return true
				end
			end
		end
		return false
	end


--
-- Determines if one node is a parent if another.
--
-- @param n
--    The node being tested for parentage.
-- @param child
--    The child node being testing against.
-- @return
--    True if n is a parent of child.
--

	function tree.isparent(n, child)
		local p = child.parent
		while p do
			if p == n then
				return true
			end
			p = p.parent
		end
		return false
	end


--
-- Remove a node from a tree.
--
-- @param node
--    The node to remove.
--

	function tree.remove(node)
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
-- @param fn
--    An optional comparator function.
--

	function tree.sort(tr, fn)
		if not fn then
			fn = function(a,b) return a.name < b.name end
		end
		tree.traverse(tr, {
			onnode = function(node)
				table.sort(node.children, fn)
			end
		}, true)
	end


--
-- Traverse a tree.
--
-- @param t
--    The tree to traverse.
-- @param fn
--    A collection of callback functions, which may contain any or all of the
--    following entries. Entries are called in this order.
--
--    onnode         - called on each node encountered
--    onbranchenter  - called on branches, before processing children
--    onbranch       - called only on branch nodes
--    onleaf         - called only on leaf nodes
--    onbranchexit   - called on branches, after processing children
--
--    Callbacks receive two arguments: the node being processed, and the
--    current traversal depth.
--
-- @param includeroot
--    True to include the root node in the traversal, otherwise it will be skipped.
-- @param initialdepth
--    An optional starting value for the traversal depth; defaults to zero.
--

	function tree.traverse(t, fn, includeroot, initialdepth)

		-- forward declare my handlers, which call each other
		local donode, dochildren

		-- process an individual node
		donode = function(node, fn, depth)
			if node.isremoved then
				return
			end

			if fn.onnode then
				fn.onnode(node, depth)
			end

			if #node.children > 0 then
				if fn.onbranchenter then
					fn.onbranchenter(node, depth)
				end
				if fn.onbranch then
					fn.onbranch(node, depth)
				end
				dochildren(node, fn, depth + 1)
				if fn.onbranchexit then
					fn.onbranchexit(node, depth)
				end
			else
				if fn.onleaf then
					fn.onleaf(node, depth)
				end
			end
		end

		-- this goofy iterator allows nodes to be removed during the traversal
		dochildren = function(parent, fn, depth)
			local i = 1
			while i <= #parent.children do
				local node = parent.children[i]
				donode(node, fn, depth)
				if node == parent.children[i] then
					i = i + 1
				end
			end
		end

		-- set a default initial traversal depth, if one wasn't set
		if not initialdepth then
			initialdepth = 0
		end

		if includeroot then
			donode(t, fn, initialdepth)
		else
			dochildren(t, fn, initialdepth)
		end
	end


--
-- Starting at the top of the tree, remove nodes that contain only a single
-- item until I hit a node that has multiple items. This is used to remove
-- superfluous folders from the top of the source tree.
--

	function tree.trimroot(tr)
		local trimmed

		-- start by removing single-children folders from the top of the tree
		while #tr.children == 1 do
			local node = tr.children[1]

			-- if this node has no children (it is the last node in the tree) I'm done
			if #node.children == 0 or node.trim == false then
				break
			end

			-- remove this node from the tree, and move its children up a level
			trimmed = true
			local numChildren = #node.children
			for i = 1, numChildren do
				local child = node.children[i]
				child.parent = node.parent
				tr.children[i] = child
			end
		end

		-- found the top, now remove any single-children ".." folders from here
		local dotdot
		local count = #tr.children
		repeat
			dotdot = false
			for i = 1, count do
				local node = tr.children[i]
				if node.name == ".." and #node.children == 1 then
					local child = node.children[1]
					child.parent = node.parent
					tr.children[i] = child
					trimmed = true
					dotdot = true
				end
			end
		until not dotdot

		-- if nodes were removed, adjust the paths on all remaining nodes
		if trimmed then
			tree.traverse(tr, {
				onnode = function(node)
					if node.parent.path then
						node.path = path.join(node.parent.path, node.name)
					else
						node.path = node.name
					end
				end
			}, false)
		end
	end
