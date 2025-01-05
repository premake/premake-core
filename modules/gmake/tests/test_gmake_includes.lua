--
-- test_gmake_includes.lua
-- Validate the link step generation for makefiles.
-- (c) 2016-2023 Jess Perkins and the Premake project
--

local suite = test.declare("gmake_includes")

local p = premake
local gmake = p.modules.gmake

local project = p.project


--
-- Setup and teardown
--

local wks, prj

function suite.setup()
    wks, prj = test.createWorkspace()
end

local function prepare(calls)
    local cfg = test.getconfig(prj, "Debug")
    local toolset = p.tools.gcc
    gmake.cpp.includes(cfg, toolset)
end


--
-- Check for idirafter flags
--

function suite.includeDirsAfter()
    includedirsafter { 'DirAfter' }
    prepare()
    test.capture [[
INCLUDES += -idirafter DirAfter
    ]]
end
