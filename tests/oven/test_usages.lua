---
-- tests/oven/test_usages.lua
-- Test the building of usages
-- Copyright (c) 2014-2025 Jess Perkins and the Premake project
---

	local p = premake
	local suite = test.declare("oven_usages")
	local oven = p.oven

---
-- Setup
---

    local wks, prj

    function suite.setup()
        wks = workspace("MyWorkspace")
        configurations { "Debug", "Release" }
        platforms { "x86", "x86_64" }
        
        prj = project "MyProject1"
            usage "PUBLIC"
                defines { "PROJECT_1_PUBLIC" }
            usage "INTERFACE"
                defines { "PROJECT_1_INTERFACE" }
            usage "PRIVATE"
                defines { "PROJECT_1_PRIVATE" }
    end

---
-- Tests to ensure that the PUBLIC and PRIVATE usages are correctly applied to the owning project
---
    function suite.singleproject_checkusages()
        p.oven.bake()

        local cfg = test.getconfig(prj, "Debug", "x86")
        test.isequal({ "PROJECT_1_PUBLIC", "PROJECT_1_PRIVATE" }, cfg.defines) -- Interface defines should not be included
    end

---
-- Tests to ensure that the PUBLIC and INTERFACE usages are correctly applied to the dependent project
---
    function suite.twoprojects_withdependency()
        prj2 = project "MyProject2"
            usage "PUBLIC"
                defines { "PROJECT_2_PUBLIC" }
            usage "INTERFACE"
                defines { "PROJECT_2_INTERFACE" }
            usage "PRIVATE"
                defines { "PROJECT_2_PRIVATE" }
            
            uses {  "MyProject1" }

        p.oven.bake()

        local cfg = test.getconfig(prj2, "Debug", "x86")

        -- Order is important here, as the test treats different order as a failure
        -- However, the order of the defines is not important in the actual implementation
        test.isequal({ "PROJECT_2_PUBLIC", "PROJECT_1_PUBLIC", "PROJECT_1_INTERFACE", "PROJECT_2_PRIVATE" }, cfg.defines) -- Interface defines should not be included
    end

---
-- Tests to ensure that the PUBLIC and INTERFACE usages are correctly applied to the dependent project via a transitve dependency
---
    function suite.multipleprojects_transitivedependency()
        prj2 = project "MyProject2"
            usage "PUBLIC"
                defines { "PROJECT_2_PUBLIC" }
                uses {  "MyProject1" }
            usage "INTERFACE"
                defines { "PROJECT_2_INTERFACE" }
            usage "PRIVATE"
                defines { "PROJECT_2_PRIVATE" }
            
        prj3 = project "MyProject3"
            uses {  "MyProject2" }
            defines { "PROJECT_3" }

        p.oven.bake()

        local cfg = test.getconfig(prj3, "Debug", "x86")

        -- Order is important here, as the test treats different order as a failure
        -- However, the order of the defines is not important in the actual implementation
        test.isequal({ "PROJECT_3", "PROJECT_1_PUBLIC", "PROJECT_1_INTERFACE", "PROJECT_2_PUBLIC", "PROJECT_2_INTERFACE" }, cfg.defines)
    end

---
-- Test to ensure that usages with custom names
---
    function suite.twoprojects_customname()
        prj2 = project "MyProject2"
            uses { "Custom" }
            usage "Custom"
                defines { "MY_CUSTOM_USAGE" }

        p.oven.bake()

        local cfg = test.getconfig(prj2, "Debug", "x86")

        -- Order is important here, as the test treats different order as a failure
        -- However, the order of the defines is not important in the actual implementation
        test.isequal({ "MY_CUSTOM_USAGE" }, cfg.defines)
    end


    function suite.multipleprojects_customname_transitive()
        prj2 = project "MyProject2"
            usage "Custom"
                defines { "MY_CUSTOM_USAGE" }
            
        prj3 = project "MyProject3"
            usage "Custom2"
                uses { "Custom" }

        prj4 = project "MyProject4"
            uses { "Custom2" }

        p.oven.bake()

        local cfg = test.getconfig(prj4, "Debug", "x86")

        -- Order is important here, as the test treats different order as a failure
        -- However, the order of the defines is not important in the actual implementation
        test.isequal({ "MY_CUSTOM_USAGE" }, cfg.defines) -- Interface defines should not be included
    end


    function suite.twoprojects_noprojectinheritance()
        -- Ensure that no variables come in from the default project scope

        prj2 = project "MyProject2"
            defines { "IMPLICIT_PRIVATE_DEFINE" }
            usage "PUBLIC"
                defines { "PROJECT_2_PUBLIC" }

        prj3 = project "MyProject3"
            uses { "MyProject2" }

        p.oven.bake()

        local cfg = test.getconfig(prj3, "Debug", "x86")

        -- Ensure that the implicit scope's define is not included
        test.isequal({ "PROJECT_2_PUBLIC" }, cfg.defines)
    end
