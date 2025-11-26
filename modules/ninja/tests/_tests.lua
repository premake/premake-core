--
-- _tests.lua
-- Test manifest for the ninja module
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

require("ninja")

return {
    "test_build_rules.lua",
    "test_ninja_config.lua",
    "test_ninja_custom_build.lua",
    "test_ninja_pch.lua",
    "test_ninja_project.lua",
    "test_ninja_workspace.lua",
}