--
-- moduleresolver.lua
-- 
-- Provides a strategy for module resolution to modules that are placed within the default module's directory. 
-- 
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

    local p = premake

    p.moduleresolver = {}

    local moduleresolver = p.moduleresolver

---
-- Check whether the module is either a path to a module or a module's name.
--

    function moduleresolver.isModulePath(module)
        return string.contains(module, "/") or string.contains(module, "\\")
    end
    
--
-- Get the name of the default module's directory.
--

    function moduleresolver.getDefaultModuleDirectory()
        return ".premake"
    end
    
---
-- Get the path to the default module's directory.
--

    function moduleresolver.getDefaultModulePath(modulePath)
        return modulePath and path.join(moduleresolver.getDefaultModuleDirectory(), path.appendExtension(modulePath, ".lua")) or modulePath
    end
    
--
-- Search the module recursively, 
-- it starts at some unknown path and walks up to the root.
--

    local function searchModuleFile(searchPath, modulePath, trackedPaths)
        trackedPaths = trackedPaths or {}
        local fullpath = path.join(searchPath, modulePath)
        table.insert(trackedPaths, fullpath)
        if not os.isfile(fullpath) then
            searchPath = path.getdirectory(searchPath) 
            fullpath = searchPath ~= "." and searchModuleFile(searchPath, modulePath, trackedPaths) or nil
        end
        return fullpath, trackedPaths
    end

    moduleresolver.searchModuleFile = searchModuleFile
    
--
-- Get the relative module's path.
--

    function moduleresolver.getRelativeModulePath(currentWorkingDir, modulePath)
        return modulePath and path.getrelative(currentWorkingDir, modulePath) or modulePath
    end
    
--
-- The strategy for module resolution is as follow:
--  1. When the module is a name then:
--      1. It gets the default location that is .premake/<module> or .premake/<module>.lua
--      2. It searches the module, starting at the current working directory and walks up to the root.
--      3. It gets the relative path for the module.
--      4. Finally, if there's an error it fail-fast.
--  2. When the module is a path then it does nothing.
--  3. Finally, returns with the module.
--

    function moduleresolver.resolveModule(module)
        local originalModule = module
        if not moduleresolver.isModulePath(module) then 
            local trackedPaths
            local currentWorkingDir = os.getcwd()
            module = moduleresolver.getDefaultModulePath(module)
            module, trackedPaths = moduleresolver.searchModuleFile(currentWorkingDir, module)
            module = moduleresolver.getRelativeModulePath(currentWorkingDir, module)
            if not module then
                error(string.format("\nmodule '%s' not resolved:\n\t%s", originalModule, table.concat(trackedPaths, "\n\t")), 3)
            end
        end
        return path.replaceextension(module, "")
    end

