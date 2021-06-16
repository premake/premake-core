local path = require('path')

local PathNameTests = test.declare('PathNameTests', 'path')


function PathNameTests.getName_onDirAndExtension()
	test.isEqual('filename.ext', path.getName('folder/filename.ext'))
end


function PathNameTests.getName_onNameAndExtension()
	test.isEqual('filename.ext', path.getName('filename.ext'))
end


function PathNameTests.getName_onNameOnly()
	test.isEqual('filename', path.getName('filename'))
end
