local tree = require('tree')

local TreeHasBranchesTests = test.declare('TreeHasBranchesTests', 'tree')

local tr

function TreeHasBranchesTests.setup()
	tr = tree.new('root')
end


function TreeHasBranchesTests.hasBranches_isFalse_onEmptyTree()
	test.isFalse(tree.hasBranches(tr))
end


function TreeHasBranchesTests.hasBranches_isFalse_onSingleLevel()
	tree.add(tr, 'A')
	tree.add(tr, 'B')
	test.isFalse(tree.hasBranches(tr))
end


function TreeHasBranchesTests.hasBranches_isTrue_onTwoLevels()
	tree.add(tr, 'A')
	tree.add(tr, 'A/A1')
	tree.add(tr, 'B')
	test.isTrue(tree.hasBranches(tr))
end
