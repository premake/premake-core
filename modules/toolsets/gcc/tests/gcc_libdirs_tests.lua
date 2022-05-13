---
-- Unit tests for the GCC toolset library directory outputs.
---

local gcc = require('gcc')

local GccLibDirsTests = test.declare('GccLibDirsTests', 'gcc-toolset', 'gcc')


---
-- Unit test verifying library directories string for empty input.
--
-- Tests: gcc.getLibDirs
-- Input: {}
-- Expected Output: ''
---
function GccLibDirsTests.EmptyLibDirs()
    local libDirs = {}
    local libDirString = gcc.getLibDirs(libDirs)

    test.isEqual( '', libDirString )
end


---
-- Unit test verifying library directories string for a single library directory.
--
-- Tests: gcc.getLibDirs
-- Input: { '/my/libs' }
-- Expected Output: '-L/my/libs'
---
function GccLibDirsTests.SingleLibDirs()
    local libDirs = { '/my/libs' }
    local libDirString = gcc.getLibDirs(libDirs)

    test.isEqual( '-L/my/libs', libDirString )
end


---
-- Unit test verifying library directories string for multiple library directories.
--
-- Tests: gcc.getLibDirs
-- Input: { '/my/libs', '/some/other/libs' }
-- Expected Output: '-L/my/libs -L/some/other/libs'
---
function GccLibDirsTests.MultipleLibDirs()
    local libDirs = { '/my/libs', '/some/other/libs' }
    local libDirString = gcc.getLibDirs(libDirs)

    test.isEqual( '-L/my/libs -L/some/other/libs', libDirString )
end
