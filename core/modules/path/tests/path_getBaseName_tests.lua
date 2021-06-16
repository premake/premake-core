local path = require('path')

local PathBaseNameTests = test.declare('PathBaseNameTests', 'path')


function PathBaseNameTests.getBaseName_onDirAndExtension()
	test.isEqual('filename', path.getBaseName('folder/filename.ext'))
end


function PathBaseNameTests.getBaseName_onNameWithExtension()
	test.isEqual('filename', path.getBaseName('filename.ext'))
end


function PathBaseNameTests.getBaseName_onNameOnly()
	test.isEqual('filename', path.getBaseName('filename'))
end
