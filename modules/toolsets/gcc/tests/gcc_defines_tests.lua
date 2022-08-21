---
-- Unit tests for the GCC toolset defines outputs.
---

local gcc = require('gcc')

local GccDefinesTests = test.declare('GccDefinesTests', 'gcc-toolset', 'gcc')


---
-- Unit test verifying defines string for empty input.
--
-- Tests: gcc.getDefines
-- Input: {}
-- Expected Output: ''
---
function GccDefinesTests.EmptyDefines()
    local defs = {}
    local defString = gcc.getDefines(defs)

    test.isEqual('', defString)
end


---
-- Unit test verifying defines string for a single define.
--
-- Tests: gcc.getDefines
-- Input: { 'MY_DEFINE' }
-- Expected Output: '-DMY_DEFINE'
---
function GccDefinesTests.SingleDefine()
    local defs = { 'MY_DEFINE' }
    local defString = gcc.getDefines(defs)

    test.isEqual('-DMY_DEFINE', defString)
end


---
-- Unit test verifying defines string for multiple defines.
--
-- Tests: gcc.getDefines
-- Input: { 'MY_DEFINE, MY_OTHER_DEFINE' }
-- Expected Output: '-DMY_DEFINE -DMY_OTHER_DEFINE'
---
function GccDefinesTests.MultipleDefine()
    local defs = { 'MY_DEFINE', 'MY_OTHER_DEFINE' }
    local defString = gcc.getDefines(defs)

    test.isEqual('-DMY_DEFINE -DMY_OTHER_DEFINE', defString)
end
