local tree = require('tree')

local TreeSortTests = test.declare('TreeSortTests', 'tree')


local tr

function TreeSortTests.setup()
	tr = tree.new('root')
end


function TreeSortTests.sort_sortsAllLevels()
	tree.add(tr, 'B/B3')
	tree.add(tr, 'B/B1/B1.2')
	tree.add(tr, 'A/A2')
	tree.add(tr, 'A/A1')
	tree.add(tr, 'B/B2')
	tree.add(tr, 'B/B1/B1.1')
	tree.sort(tr)
	test.capture([[
root
--A
----A1
----A2
--B
----B1
------B1.1
------B1.2
----B2
----B3
	]], tree.toString(tr))
end
