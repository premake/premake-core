--
-- tests/base/test_tree.lua
-- Automated test suite source code tree handling.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.tree = { }
	local tree = premake.tree


--
-- Setup/teardown
--

	local tr, nodes
			
	function T.tree.setup()
		tr = tree.new()
		nodes = { }
	end

	local function getresult()
		tree.traverse(tr, {
			onnode = function(node, depth)
				table.insert(nodes, string.rep(".", depth) .. node.name)
			end
		})
		return table.concat(nodes)
	end

	

--
-- Tests for tree.new()
--

	function T.tree.NewReturnsObject()
		test.isnotnil(tr)
	end


--
-- Tests for tree.add()
--

	function T.tree.CanAddAtRoot()
		tree.add(tr, "Root")
		test.isequal(""
			.. "Root",
			getresult())
	end

	function T.tree.CanAddAtChild()
		tree.add(tr, "Root/Child")
		test.isequal(""
			.. "Root"
			.. ".Child",
			getresult())
	end

	function T.tree.CanAddAtGrandchild()
		tree.add(tr, "Root/Child/Grandchild")
		test.isequal(""
			.. "Root"
			.. ".Child"
			.. "..Grandchild",
			getresult())
	end

