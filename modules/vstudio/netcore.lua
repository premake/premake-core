--
-- netcore.lua
-- Extend the existing exporters with support for .NET Core targets.
-- Copyright (c) Jason Perkins and the Premake project
--

local p = premake
local vstudio = p.vstudio

---
-- Define the .NET Core export action.
---

newaction {
    -- Metadata for the command line and help system

    trigger     = "netcore",
    shortname   = ".NET Core (MSBuild)",
    description = "Generate .NET Core MSBuild project files.",

    -- Visual Studio always uses Windows path and naming conventions

    targetos = "windows",
    toolset  = "dotnet",

    -- The capabilities of this action

    valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None", "Utility" },
    valid_languages = { "C#", "F#" },
    valid_tools     = {
        dotnet = { "msnet" },
    },

    -- Workspace and project generation logic

    onWorkspace = function(wks)
        p.vstudio.vs2005.generateSolution(wks)
    end,
    onProject = function(prj)
        p.vstudio.vs2010.generateProject(prj)
    end,
    onRule = function(rule)
        p.vstudio.vs2010.generateRule(rule)
    end,

    onCleanWorkspace = function(wks)
        p.vstudio.cleanSolution(wks)
    end,
    onCleanProject = function(prj)
        p.vstudio.cleanProject(prj)
    end,
    onCleanTarget = function(prj)
        p.vstudio.cleanTarget(prj)
    end,

    pathVars = vstudio.vs2010.pathVars,


    -- This stuff is specific to the Visual Studio exporters

    vstudio = {
        solutionVersion = "12",
        versionName     = "15",
        targetFramework = "netstandard2.0",
    }
}
