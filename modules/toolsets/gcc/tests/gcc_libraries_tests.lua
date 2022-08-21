---
-- Unit tests for the GCC toolset library outputs.
---

local gcc = require('gcc')

local GccLibrariesTests = test.declare('GccLibrariesTests', 'gcc-toolset', 'gcc')


---
-- Unit test verifying library string for empty input.
--
-- Tests: gcc.getLibraries
-- Input: {}
-- Expected Output: ''
---
function GccLibrariesTests.EmptyLibDirs()
    local libs = {}
    local libString = gcc.getLibraries(libs)

    test.isEqual( '', libString )
end


---
-- Unit test verifying library string for a single library.
--
-- Tests: gcc.getLibraries
-- Input: { 'MyLib' }
-- Expected Output: '-lMyLib'
---
function GccLibrariesTests.SingleLibDirs()
    local libs = { 'MyLib' }
    local libString = gcc.getLibraries(libs)

    test.isEqual( '-lMyLib', libString )
end


---
-- Unit test verifying library string for multiple libraries.
--
-- Tests: gcc.getLibraries
-- Input: { 'MyLib', 'MyOtherLib' }
-- Expected Output: '-lMyLib -lMyOtherLib'
---
function GccLibrariesTests.MultipleLibDirs()
    local libs = { 'MyLib', 'MyOtherLib' }
    local libString = gcc.getLibraries(libs)

    test.isEqual( '-lMyLib -lMyOtherLib', libString )
end
