---
-- GCC toolset.
---

local gcc = {}
gcc.base = doFile('./src/base.lua', gcc)


---
-- Gets if an architecture is supported.
---
function gcc.isSupportedArch(arch)
    return arch == "x86" or arch == "x86_64"
end


---
-- Gets the architecture flags for a given architecture
--
-- @param arch
--    Architecture to get compiler and linker flags for
-- @returns
--    String representing the machine architecture compiler switch, or nil
---
function gcc.getArchitectureFlags(arch)

    if arch == "x86" then
        return "-m32"
    elseif arch == "x86_64" then
        return "-m64"
    end

    return nil

end


---
-- Gets the system library directories for a given architecture
--
-- @param arch
--    Architecture to get system library directories for
-- @returns
--    String representing path to the system library directory for the architecture, or nil
---
function gcc.getSystemLibDirs(arch)

    if arch == "x86" then
        return "/usr/lib32"
    elseif arch == "x86_64" then
        return "/usr/lib64"
    end

    return nil

end

---
-- @param defines
--    Table containing all defines
-- @returns
--    A string containing the defines
--
-- Source: https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
---
function gcc.getDefines(defines)
    local defs = table.map(defines, function(key, value)
        return '-D' .. value
    end)

    return table.concat(defs, ' ')
end


---
-- @param includes
--    Table containing all includes, relative to the project or an absolute path
-- @returns
--    A string containing the includes
--
-- Source: https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html
---
function gcc.getIncludes(includes)
    local incs = table.map(includes, function(key, value)
        return '-I' .. value
    end)

    return table.concat(incs, ' ')
end


---
-- @param dirs
--    Table containing all library search directories, relative to the project or an absolute path
-- @returns
--    A string containing the library directories
--
-- Source: https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html
---
function gcc.getLibDirs(dirs)
    local dirs = table.map(dirs, function(key, value)
        return '-L' .. value
    end)

    return table.concat(dirs, ' ')
end


---
-- @param dirs
--    Table containing all libraries to link to
-- @returns
--    A string containing the libraries to link to
--
-- Source: https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
---
function gcc.getLibraries(libs)
    local lib = table.map(libs, function(key, value)
        return '-l' .. value
    end)

    return table.concat(lib, ' ')
end


---
-- Computes the premake flag as a GCC argument. If a GCC version is provided, this attempts
-- to use mapping for the specific GCC version first, then falls back on the base GCC implementation.
--
-- @param flag
--    Flag to map value of
-- @param value [Optional]
--    Value of flag to map
-- @param version
--    Version of the toolset to get value from
-- @returns
--    GCC argument mapped from a premake flag-value pair. If flag could not be mapped, returns nil.
---
function gcc.mapFlag(flag, value, version)
    if not version then
        return gcc.base.mapFlag(flag, value)
    else
        return gcc[version].mapFlag(flag, value) or gcc.base.mapFlag(flag, value)
    end
end


return gcc;