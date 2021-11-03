---
-- A tree data structure to make working with source file hierarchies a little easier.
---

local path = require('path')

local tree = {}

tree.INCLUDE_ROOT = 1


---
-- Create a new, empty instance of a tree.
--
-- @param rootName
--    A name for the root node of the tree; optional.
---

function tree.new(rootName)
	return {
		name = rootName,
		children = _EMPTY
	}
end


---
-- Add an item to a tree. If the item is already in the tree, nothing is added.
--
-- @param itemPath
--    The new path to be added to the tree.
-- @returns
--    The added item. If the item was already present in the tree, the existing
--    item is returned.
---

function tree.add(self, itemPath)
	if itemPath == '.' or itemPath == '/' then
		return self
	end

	-- If needed, recurse to create any intermediate folder nodes needed by the path
	local parentNode = tree.add(self, path.getDirectory(itemPath))

	-- Check to see if this node is already present in the tree
	local itemName = path.getName(itemPath)
	local itemNode = parentNode.children[itemName]
	if itemNode ~= nil then
		return itemNode
	end

	-- Nope, go ahead and create the new node...
	itemNode = tree.new(itemName)
	itemNode.path = itemPath
	itemNode.parent = parentNode

	-- ...and add it to its parent node, keyed by both the file name for quick lookup
	-- and indexed to maintain the original ordering
	if parentNode.children == _EMPTY then
		parentNode.children = {}
	end

	parentNode.children[itemName] = itemNode
	table.insert(parentNode.children, itemNode)

	return itemNode
end


---
-- Find all nodes which match the provided predicate.
--
-- @param predicate
--    A function receiving node and depth arguments; returning `true` to add the given
--    node to the results.
-- @returns
--    All nodes which passed the predicate.
---

function tree.find(self, predicate)
	local result = {}

	tree.traverse(self, {
		onNode = function (node, depth)
			if predicate(node, depth) then
				table.insert(result, node)
			end
		end
	}, tree.INCLUDE_ROOT)

	return result
end


---
-- Returns `true` if a tree has branches, or `false` if it is a single level of leaves.
---

function tree.hasBranches(self)
	local children = self.children
	for i = 1, #children do
		local child = children[i]
		if #child.children > 0 then
			return true
		end
	end
	return false
end


---
-- Sort all levels of the tree, in place.
--
-- @param compareFn
--    An optional comparator function. If not provided items will sorted
--    alphabetically by name.
--

function tree.sort(self, compareFn)
	compareFn = compareFn or function(a,b) return a.name < b.name end
	tree.traverse(self, {
		onNode = function (node)
			table.sort(node.children, compareFn)
		end
	}, tree.INCLUDE_ROOT)
end


---
-- Returns a simplified text view of the tree, for testing.
---

function tree.toString(self)
	local rows = {}

	tree.traverse(self, {
		onNode = function(node, depth)
			table.insert(rows, string.rep('--', depth) .. (node.name or '(nil)'))
		end
	}, tree.INCLUDE_ROOT)

	return table.concat(rows, '\n')
end


---
-- Traverse a tree.
--
-- @param callbacks
--    A collection of callback functions, which may contain any or all of the following
--    entries. Entries are called in this order:
--
--      onNode         - called on both branches and leaves
--      onBranchEnter  - called on branches, before processing children
--      onLeaf         - called only on leaf nodes
--      onBranchExit   - called on branches, after processing children
--
--    Callbacks take the form `function (node, depth)`.
-- @param options
--    Traversal options. Currently only `tree.INCLUDE_ROOT` is available, which includes
--    the root node in the traversal callbacks. May be `nil` for defaults.
-- @param initialDepth
--    An optional starting value for the traversal depth; defaults to zero.
---

function tree.traverse(self, callbacks, options, initialDepth)
	local processNode, processChildren
	local depth = initialDepth or 0

	processNode = function (node, depth)
		if callbacks.onNode then
			callbacks.onNode(node, depth)
		end

		if #node.children == 0 and depth > 0 then
			if callbacks.onLeaf then
				callbacks.onLeaf(node, depth)
			end
		else
			if callbacks.onBranchEnter then
				callbacks.onBranchEnter(node, depth)
			end
			processChildren(node, depth + 1)
			if callbacks.onBranchExit then
				callbacks.onBranchExit(node, depth)
			end
		end
	end

	processChildren = function (node, depth)
		-- jump through hoops to allow nodes to be removed during traversal
		local i = 1
		while i <= #node.children do
			local childNode = node.children[i]
			processNode(childNode, depth)
			if childNode == node.children[i] then
				i = i + 1
			end
		end
	end

	if options == tree.INCLUDE_ROOT then
		processNode(self, depth)
	else
		processChildren(self, depth + 1)
	end
end


return tree
