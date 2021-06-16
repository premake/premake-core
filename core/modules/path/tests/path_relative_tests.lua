local path = require('path')

local PathRelativeTests = test.declare('PathRelativeTests', 'path')


---
-- If both paths match exactly, return '.'
---

function PathRelativeTests.onMatchingPaths()
	test.isEqual('.', path.getRelative('/a/b/c', '/a/b/c'))
end


---
-- If the target is a single level above the base, return '..'
---

function PathRelativeTests.onTargetOneLevelAboveBase()
	test.isEqual('..', path.getRelative('/a/b/c', '/a/b'))
end


---
-- If the target is multiple levels above, return the corresponding number of '..'
---

function PathRelativeTests.onTargetMultipleLevelsAboveBase()
	test.isEqual('../..', path.getRelative('/a/b/c/d', '/a/b'))
end


---
-- If the base and target are siblings...
---

function PathRelativeTests.onSiblings()
	test.isEqual('../d', path.getRelative('/a/b/c', '/a/b/d'))
end


---
-- If the target is a single level below the base, return just the directory name
---

function PathRelativeTests.onSingleLevelBelow()
	test.isEqual('c', path.getRelative('/a/b', '/a/b/c'))
end


---
-- Should work with drives and servers
---

function PathRelativeTests.onWindowsDrive()
	test.isEqual('../Premake6', path.getRelative('C:/Code/Premake5', 'C:/Code/Premake6'))
end

function PathRelativeTests.onServerName()
	test.isEqual('../Premake6', path.getRelative('//server/Code/Premake5', '//server/Code/Premake6'))
end


---
-- If target starts with an entirely different root folder, return the full target path
---

function PathRelativeTests.onDifferentRoots()
	test.isEqual('/Projects/Premake', path.getRelative('/Code/Premake', '/Projects/Premake'))
end

function PathRelativeTests.onDifferentWindowsRoots()
	test.isEqual('C:/Projects/Premake', path.getRelative('C:/Code/Premake', 'C:/Projects/Premake'))
end

function PathRelativeTests.onDifferentWindowsDrives()
	test.isEqual('D:/Code/Premake', path.getRelative('C:/Code/Premake', 'D:/Code/Premake'))
end

function PathRelativeTests.onDifferentServers()
	test.isEqual('//Projects/Premake', path.getRelative('//Code/Premake', '//Projects/Premake'))
end


---
-- Leading macros should be treated like absolute paths
---

function PathRelativeTests.onLeadingDollarMacro()
	test.isEqual('$(SDK_HOME)/include', path.getRelative('C:/Code/Premake', '$(SDK_HOME)/include'))
end


---
-- Extra slashes in paths should be ignored
---

function PathRelativeTests.ignoresExtraSlashes2()
	test.isEqual('..', path.getRelative('/a//b/c','/a/b'))
end

function PathRelativeTests.ignoresExtraSlashes3()
	test.isEqual('..', path.getRelative('/a///b/c','/a/b'))
end

function PathRelativeTests.ignoresTrailingSlashes()
	test.isEqual('c', path.getRelative('/a/b/','/a/b/c'))
end


---
-- Relative files in the same directory should return just the target file name
---

function PathRelativeTests.getRelativeFile_onSameDirectory()
	test.isEqual('bye.txt', path.getRelativeFile('/a/b/hello.txt', '/a/b/bye.txt'))
end


---
-- Works with arrays of paths.
---

function PathRelativeTests.onArrayOfPaths()
	test.isEqual({ 'c', 'd' }, path.getRelative('/a/b', { '/a/b/c', '/a/b/d' }))
end

function PathRelativeTests.getRelativeFile_onArrayOfPaths()
	test.isEqual({ 'bye.txt', 'adios.txt' }, path.getRelativeFile('/a/b/hello.txt', { '/a/b/bye.txt', '/a/b/adios.txt' }))
end
