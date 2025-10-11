--
-- _preload.lua
-- Define the ninja actions
-- Author: Nick Clark
-- Copyright (c) Jess Perkins and the Premake project
--

local p = premake
local project = p.project

newaction {
    trigger     = "ninja",
    shortname   = "Ninja",
    description = "Generate Ninja build files",

    -- Action Capabilities
    valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "None" },
    valid_languages = { "C", "C++" },
    valid_tools = {
        cc = {
            "gcc",
            "clang",
            "msc",
            "emcc",
            "cosmocc",
        }
    },
    toolset = (function()
        local target = os.target()
        if target == p.MACOSX then
            return "clang"
        elseif target == p.EMSCRIPTEN then
            return "emcc"
        elseif target == p.WINDOWS then
            return "v143"
        else
            return "gcc"
        end
    end)(),

    -- Workspace and project generation functions
    onInitialize = function()
        require("ninja")
    end,
    onWorkspace = function(wks)
        p.escaper(p.modules.ninja.esc)
        wks.projects = table.filter(wks.projects, function(prj)
            return p.action.supports(prj.kind) and prj.kind ~= p.NONE
        end)
        p.generate(wks, p.modules.ninja.getninjafilename(wks, false), p.modules.ninja.wks.generate)
    end,
    onProject = function(prj)
        p.escaper(p.modules.ninja.esc)

        if not p.action.supports(prj.kind) or prj.kind == p.NONE then
            return
        end

        if project.isc(prj) or project.iscpp(prj) then
            for cfg in project.eachconfig(prj) do
                local filename = p.modules.ninja.getprjconfigfilename(cfg)
                p.generate(prj, filename, p.modules.ninja.cpp.generate)
            end
        else
            p.warn("Ninja does not support the '%s' language. No build file generated for project '%s'.", prj.language, prj.name)
        end
    end,
}

return function(cfg)
    return (_ACTION == "ninja")
end
