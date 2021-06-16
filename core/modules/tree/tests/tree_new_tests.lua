local tree = require('tree')

local TreeNewTests = test.declare('TreeNewTests', 'tree')


function TreeNewTests.new_returnsInstance()
	test.isNotNil(tree.new())
end


function TreeNewTests.new_assignsRootName()
	local tr = tree.new('RootNode')
	test.capture([[
RootNode
	]], tree.toString(tr))
end
