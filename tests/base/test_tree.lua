--
-- tests/base/test_tree.lua
-- Automated test suite source code tree handling.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	local suite = test.declare("base_tree")
	local tree = premake.tree


--
-- Setup/teardown
--

	local tr

	function suite.setup()
		tr = tree.new()
	end

	local function prepare()
		tree.traverse(tr, {
			onnode = function(node, depth)
				_p(depth + 2, node.name)
			end
		})
	end


--
-- Tests for tree.new()
--

	function suite.NewReturnsObject()
		test.isnotnil(tr)
	end


--
-- Tests for tree.add()
--

	function suite.CanAddAtRoot()
		tree.add(tr, "Root")
		prepare()
		test.capture [[
		Root
		]]
	end

	function suite.CanAddAtChild()
		tree.add(tr, "Root/Child")
		prepare()
		test.capture [[
		Root
			Child
		]]
	end

	function suite.CanAddAtGrandchild()
		tree.add(tr, "Root/Child/Grandchild")
		prepare()
		test.capture [[
		Root
			Child
				Grandchild
		]]
	end


--
-- Tests for tree.getlocalpath()
--

	function suite.GetLocalPath_ReturnsPath_OnNoParentPath()
		local c = tree.add(tr, "Root/Child")
		c.parent.path = nil
		test.isequal("Root/Child", tree.getlocalpath(c))
	end

	function suite.GetLocalPath_ReturnsName_OnParentPathSet()
		local c = tree.add(tr, "Root/Child")
		test.isequal("Child", tree.getlocalpath(c))
	end


--
-- Tests for tree.remove()
--

	function suite.Remove_RemovesNodes()
		local n1 = tree.add(tr, "1")
		local n2 = tree.add(tr, "2")
		local n3 = tree.add(tr, "3")
		tree.remove(n2)
		local r = ""
		for _, n in ipairs(tr.children) do r = r .. n.name end
		test.isequal("13", r)
	end


	function suite.Remove_WorksInTraversal()
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


--
-- Tests for tree.sort()
--

	function suite.Sort_SortsAllLevels()
		tree.add(tr, "B/3")
		tree.add(tr, "B/1")
		tree.add(tr, "A/2")
		tree.add(tr, "A/1")
		tree.add(tr, "B/2")
		tree.sort(tr)
		prepare()
		test.capture [[
		A
			1
			2
		B
			1
			2
			3
		]]
	end


--
-- If the root of the tree contains multiple items, it should not
-- be removed by trimroot()
--

	function suite.trimroot_onItemsAtRoot()
		tree.add(tr, "A/1")
		tree.add(tr, "B/1")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		A
			1
		B
			1
		]]
	end


--
-- Should trim to first level with multiple items.
--

	function suite.trimroot_onItemsInFirstNode()
		tree.add(tr, "A/1")
		tree.add(tr, "A/2")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		1
		2
		]]
	end


--
-- If the tree contains only a single node, don't trim it.
--

	function suite.trimroot_onSingleNode()
		tree.add(tr, "A")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		A
		]]
	end


--
-- If the tree contains only a single node, don't trim it.
--

	function suite.trimroot_onSingleLeafNode()
		tree.add(tr, "A/1")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		1
		]]
	end


--
-- A ".." folder containing a single subfolder should never appear
-- at the top of the source tree.
--

	function suite.trimroot_removesDotDot_onTopLevelSiblings()
		tree.add(tr, "../../tests/test_hello.c")
		tree.add(tr, "../src/test.c")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		tests
			test_hello.c
		src
			test.c
		]]
	end

	function suite.trimroot_removesDotDot_onTopLevel()
		tree.add(tr, "../tests/test_hello.c")
		tree.add(tr, "src/test.c")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		tests
			test_hello.c
		src
			test.c
		]]
	end

	function suite.trimroot_removesDotDot_onMultipleNestings()
		tree.add(tr, "../../../tests/test_hello.c")
		tree.add(tr, "../src/test.c")
		tree.trimroot(tr)
		prepare()
		test.capture [[
		tests
			test_hello.c
		src
			test.c
		]]
	end


--
-- When nodes are trimmed, the paths on the remaining nodes should
-- be updated to reflect the new hierarchy.
--

	function suite.trimroot_updatesPaths_onNodesRemoved()
		tree.add(tr, "A/1")
		tree.add(tr, "A/2")
		tree.trimroot(tr)
		test.isequal("1", tr.children[1].path)
	end


	function suite.trimroot_updatesPaths_onDotDotRemoved()
		tree.add(tr, "../../../tests/test_hello.c")
		tree.add(tr, "../src/test.c")
		tree.trimroot(tr)
		test.isequal("tests", tr.children[1].path)
	end


--
-- Nodes with the key "trim" set to false should be removed.
--

	function suite.trimroot_respectsTrimFlag()
		local n = tree.add(tr, "A")
		tree.add(tr, "A/1")
		n.trim = false
		tree.trimroot(tr)
		prepare()
		test.capture [[
		A
			1
		]]
	end
