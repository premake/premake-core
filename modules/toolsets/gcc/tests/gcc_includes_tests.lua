---
-- Unit tests for the GCC toolset include outputs.
---

local gcc = require('gcc')

local GccIncludesTests = test.declare('GccIncludesTests', 'gcc-toolset', 'gcc')


---
-- Unit test verifying includes string for empty input.
--
-- Tests: gcc.getIncludes
-- Input: {}
-- Expected Output: ''
---
function GccIncludesTests.EmptyIncludes()
    local incs = {}
    local incString = gcc.getIncludes(incs)

    test.isEqual( '', incString )
end


---
-- Unit test verifying includes string for a single include.
--
-- Tests: gcc.getIncludes
-- Input: { '/my/include' }
-- Expected Output: '-I/my/include'
---
function GccIncludesTests.SingleInclude()
    local incs = { '/my/include' }
    local incString = gcc.getIncludes(incs)

    test.isEqual( '-I/my/include', incString )
end


---
-- Unit test verifying includes string for multiple includes.
--
-- Tests: gcc.getIncludes
-- Input: { '/my/include', '/some/other/include' }
-- Expected Output: '-I/my/include -I/some/other/include'
---
function GccIncludesTests.MultipleIncludes()
    local incs = { '/my/include', '/some/other/include' }
    local incString = gcc.getIncludes(incs)

    test.isEqual( '-I/my/include -I/some/other/include', incString )
end
