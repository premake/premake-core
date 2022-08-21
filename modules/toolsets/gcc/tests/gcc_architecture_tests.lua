---
-- Unit tests for the GCC toolset architecture outputs.
---

local gcc = require('gcc')

local GccArchitectureTests = test.declare('GccArchitectureTests', 'gcc-toolset', 'gcc')


---
-- Unit test verifying if x86 is supported.
--
-- Tests: gcc.isSupportedArch
-- Input: x86
-- Expected Output: True
---
function GccArchitectureTests.IsSupportedArchX86()
    local arch = 'x86'
    local supported = gcc.isSupportedArch(arch)

    test.isTrue(supported)
end


---
-- Unit test verifying if x86_64 is supported.
--
-- Tests: gcc.isSupportedArch
-- Input: x86_64
-- Expected Output: True
---
function GccArchitectureTests.IsSupportedArchX8664()
    local arch = 'x86_64'
    local supported = gcc.isSupportedArch(arch)

    test.isTrue(supported)
end


---
-- Unit test verifying if nil architecture is supported.
--
-- Tests: gcc.isSupportedArch
-- Input: nil
-- Expected Output: False
---
function GccArchitectureTests.IsSupportedArchNil()
    local arch = nil
    local supported = gcc.isSupportedArch(arch)

    test.isFalse(supported)
end


---
-- Unit test verifying if ARM is supported.
--
-- Tests: gcc.isSupportedArch
-- Input: ARM
-- Expected Output: True
---
function GccArchitectureTests.IsSupportedArchArm()
    local arch = 'ARM'
    local supported = gcc.isSupportedArch(arch)

    test.isFalse(supported)
end


---
-- Unit test verifying architecture flags for x86.
--
-- Tests: gcc.getArchitectureFlags
-- Input: x86
-- Expected Output: -m32
---
function GccArchitectureTests.GetArchitectureFlagsX86()
    local arch = 'x86'
    local flags = gcc.getArchitectureFlags(arch)

    test.isEqual( '-m32', flags )
end


---
-- Unit test verifying architecture flags for x86_64.
--
-- Tests: gcc.getArchitectureFlags
-- Input: x86_64
-- Expected Output: -m64
---
function GccArchitectureTests.GetArchitectureFlagsX8664()
    local arch = 'x86_64'
    local flags = gcc.getArchitectureFlags(arch)

    test.isEqual( '-m64', flags )
end


---
-- Unit test verifying architecture flags for nil.
--
-- Tests: gcc.getArchitectureFlags
-- Input: nil
-- Expected Output: nil
---
function GccArchitectureTests.GetArchitectureFlagsNil()
    local arch = nil
    local flags = gcc.getArchitectureFlags(arch)

    test.isNil(flags)
end


---
-- Unit test verifying architecture flags for ARM.
--
-- Tests: gcc.getArchitectureFlags
-- Input: ARM
-- Expected Output: nil
---
function GccArchitectureTests.GetArchitectureFlagsArm()
    local arch = 'ARM'
    local flags = gcc.getArchitectureFlags(arch)

    test.isNil(flags)
end


---
-- Unit test verifying system library directory for x86.
--
-- Tests: gcc.getSystemLibDirs
-- Input: x86
-- Expected Output: /usr/lib32
---
function GccArchitectureTests.GetSystemLibDirsX86()
    local arch = 'x86'
    local dirs = gcc.getSystemLibDirs(arch)

    test.isEqual( '/usr/lib32', dirs )
end


---
-- Unit test verifying system library directory for x86_64.
--
-- Tests: gcc.getSystemLibDirs
-- Input: x86_64
-- Expected Output: /usr/lib64
---
function GccArchitectureTests.GetSystemLibDirsX8664()
    local arch = 'x86_64'
    local dirs = gcc.getSystemLibDirs(arch)

    test.isEqual( '/usr/lib64', dirs )
end


---
-- Unit test verifying system library directory for nil.
--
-- Tests: gcc.getSystemLibDirs
-- Input: nil
-- Expected Output: nil
---
function GccArchitectureTests.GetSystemLibDirsNil()
    local arch = nil
    local dirs = gcc.getSystemLibDirs(arch)

    test.isNil(dirs)
end


---
-- Unit test verifying system library directory for ARM.
--
-- Tests: gcc.getSystemLibDirs
-- Input: ARM
-- Expected Output: nil
---
function GccArchitectureTests.GetSystemLibDirsArm()
    local arch = 'ARM'
    local dirs = gcc.getSystemLibDirs(arch)

    test.isNil(dirs)
end