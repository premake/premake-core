---
-- A tree data structure to make working with source file hierarchies a little easier.
---

local path = require('path')

local tree = {}


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
-- @param item
--    The item to add
-- @returns
--    The added item. If the item was already present in the tree, the existing
--    item is returned.
---

function tree.add(self, itemPath)
	if itemPath == '.' or itemPath == '/' then
		return self
	end

	local parentNode = tree.add(self, path.getDirectory(itemPath))
	local itemName = path.getName(itemPath)
	local itemNode = parentNode.children[itemName]

	if itemNode == nil then
		itemNode = tree.new(itemName)
		itemNode.path = itemPath

		if parentNode.children == _EMPTY then
			parentNode.children = {}
		end

		parentNode.children[itemName] = itemNode
		table.insert(parentNode.children, itemNode)
	end

	return itemNode
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
	}, true)
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
	}, true)

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
-- @param includeRootNode
--    True to include the root node in the traversal, otherwise it will be skipped.
-- @param initialDepth
--    An optional starting value for the traversal depth; defaults to zero.
---

function tree.traverse(self, callbacks, includeRootNode, initialDepth)
	local processNode, processChildren
	local depth = initialDepth or 0

	processNode = function (node, depth)
		if callbacks.onNode then
			callbacks.onNode(node, depth)
		end

		if #node.children == 0 then
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

	if includeRootNode then
		processNode(self, depth)
	else
		processChildren(self, depth)
	end
end


return tree
