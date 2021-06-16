local tree = require('tree')

local TreeAddTests = test.declare('TreeAddTests', 'tree')

local tr

function TreeAddTests.setup()
	tr = tree.new('root')
end


function TreeAddTests.add_atRoot()
	tree.add(tr, 'a1')
	tree.add(tr, 'b1')
	test.capture([[
root
--a1
--b1
	]], tree.toString(tr))
end


function TreeAddTests.add_atChild()
	tree.add(tr, 'a1/a1.1')
	tree.add(tr, 'b1')
	test.capture([[
root
--a1
----a1.1
--b1
	]], tree.toString(tr))
end


function TreeAddTests.add_atGrandchild()
	tree.add(tr, 'a1/a1.1/a1.1.1')
	tree.add(tr, 'b1')
	test.capture([[
root
--a1
----a1.1
------a1.1.1
--b1
	]], tree.toString(tr))
end
