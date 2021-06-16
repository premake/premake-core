local path = require('path')

local PathDirectoryTests = test.declare('PathDirectoryTests', 'path')


function PathDirectoryTests.getDirectory_onDirAndFileName()
	test.isEqual('folder/src', path.getDirectory('folder/src/filename.ext'))
end


function PathDirectoryTests.getDirectory_onNameOnly()
	test.isEqual('.', path.getDirectory('folder'))
end
