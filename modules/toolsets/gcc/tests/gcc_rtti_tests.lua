---
-- Unit tests for the GCC toolset RTTI flags.
---

local gcc = require('gcc')

local GccRttiTests = test.declare('GccRtti', 'gcc-toolset', 'gcc')


---
-- Unit test verifying the output of mapFlag for 'rtti' with a nil value.
--
-- Tests: gcc.mapFlag
-- Input: 'rtti', nil
-- Expected Output: nil
---
function GccRttiTests.IsNil()
    local rtti = nil
    local flag = gcc.mapFlag('rtti', rtti)
    test.isNil(flag)
end


---
-- Unit test verifying the output of mapFlag for 'rtti' with default.
--
-- Tests: gcc.mapFlag
-- Input: 'rtti', 'Default'
-- Expected Output: ''
---
function GccRttiTests.IsDefault()
    local rtti = 'Default'
    local flag = gcc.mapFlag('rtti', rtti)
    test.isEqual('', flag)
end


---
-- Unit test verifying the output of mapFlag for 'rtti' with On.
--
-- Tests: gcc.mapFlag
-- Input: 'rtti', 'On'
-- Expected Output: ''
---
function GccRttiTests.IsOn()
    local rtti = 'On'
    local flag = gcc.mapFlag('rtti', rtti)
    test.isEqual('', flag)
end


---
-- Unit test verifying the output of mapFlag for 'rtti' with Off.
--
-- Tests: gcc.mapFlag
-- Input: 'rtti', 'Off'
-- Expected Output: '-fno-rtti'
---
function GccRttiTests.IsOff()
    local rtti = 'Off'
    local flag = gcc.mapFlag('rtti', rtti)
    test.isEqual('-fno-rtti', flag)
end