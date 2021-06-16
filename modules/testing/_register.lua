commandLineOption {
	trigger = 'test',
	description = 'Run the automated test suite',
	category = 'Testing',
	execute = function ()
		test = require('testing') -- add `test` to global namespace
		test.runTests()
	end
}

commandLineOption {
	trigger = '--test-only',
	value = 'SUITE[.TEST]',
	category = 'Testing',
	description = 'Run only the specified suite or test',
	default = '*'
}
