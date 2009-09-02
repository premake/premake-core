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


--
-- Tests for tree.getlocalpath()
--

	function T.tree.GetLocalPath_ReturnsPath_OnNoParentPath()
		local c = tree.add(tr, "Root/Child")
		c.parent.path = nil
		test.isequal("Root/Child", tree.getlocalpath(c))
	end

	function T.tree.GetLocalPath_ReturnsName_OnParentPathSet()
		local c = tree.add(tr, "Root/Child")
		test.isequal("Child", tree.getlocalpath(c))
	end


--
-- Tests for tree.remove()
--

	function T.tree.Remove_RemovesNodes()
		local n1 = tree.add(tr, "1")
		local n2 = tree.add(tr, "2")
		local n3 = tree.add(tr, "3")
		tree.remove(n2)
		local r = ""
		for _, n in ipairs(tr.children) do r = r .. n.name end
		test.isequal("13", r)
	end

	
	function T.tree.Remove_WorksInTraversal()
		tree.add(tr, "Root/1")
		tree.add(tr, "Root/2")
		tree.add(tr, "Root/3")
		local r = ""
		tree.traverse(tr, {
			onleaf = function(node)
				r = r .. node.name
				tree.remove(node)
			end
		})
		test.isequal("123", r)
		test.isequal(0, #tr.children[1])
	end

