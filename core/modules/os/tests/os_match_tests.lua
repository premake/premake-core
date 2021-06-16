local os = require('os')

local OsMatchTests = test.declare('OsMatchTests', 'os')

local _cwd

function OsMatchTests.setup()
	_cwd = os.getCwd()
	os.chdir(_SCRIPT_DIR)
end

function OsMatchTests.teardown()
	os.chdir(_cwd)
end


function OsMatchTests.matchDirs_onWildcard()
	local result = os.matchDirs('*')
	test.isEqual({ 'sandbox' }, result)
end


function OsMatchTests.matchDirs_onRecurse()
	local result = os.matchDirs('**')
	test.isEqual({
		'sandbox',
		'sandbox/area50',
		'sandbox/area50/src',
		'sandbox/area51',
		'sandbox/area51/src'
	}, result)
end


function OsMatchTests.matchDirs_onRecurseWithLeadingDir()
	local result = os.matchDirs('sandbox/area50/**')
	test.isEqual({
		'sandbox/area50/src'
	}, result)
end


function OsMatchTests.matchDirs_onInlineWildcard()
	local result = os.matchDirs('sandbox/*/src')
	test.isEqual({
		'sandbox/area50/src',
		'sandbox/area51/src'
	}, result)
end


function OsMatchTests.matchFiles_onRecurseWithExtension()
	local result = os.matchFiles('sandbox/**.txt')
	test.isEqual({
		'sandbox/sandbox.txt',
		'sandbox/area50/src/area50.txt',
		'sandbox/area51/src/area51.txt'
	}, result)
end
