local os = require('os')

local OsIsFileTests = test.declare('OsIsFileTests', 'os')

local _cwd

function OsIsFileTests.setup()
	_cwd = os.getCwd()
	os.chdir(_SCRIPT_DIR)
end

function OsIsFileTests.teardown()
	os.chdir(_cwd)
end


function OsIsFileTests.isFile_isTrue_onExistingFile()
	test.isTrue(os.isFile('os_isFile_tests.lua'))
end

function OsIsFileTests.isFile_isFalse_onNoSuchFile()
	test.isFalse(os.isFile('no_such_file.lua'))
end
