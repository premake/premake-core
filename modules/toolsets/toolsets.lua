---
-- Toolsets represents a collection of various C++ build tools (GCC, Clang, MSVC, etc) that a
-- user can specify in a script.  Each individual toolset defines the architectures that it is
-- valid for and mappings for turning premake fields into tool-specific outputs.
--
-- C++ toolsets must define the following functions on the toolset object:
--   * isSupportedArch(arch: string) - Returns boolean if the architecture is supported
--   * getArchitectureFlags(arch: string) - Returns a string of the flags to pass to the tool for
--        an architecture if it is supported, else nil
--   * getSystemLibDirs(arch: string) - Returns a string containing the system library directories
--        for an architecture if it is supported, else nil
--   * getDefines(defines: table) - Returns a string containing the defines formatted for direct
--        input to the toolset
--   * getIncludes(includes: table) - Returns a string containing the include directories command
--        formatted for input to the toolset
--   * getLibDirs(dirs: table) - Returns a string containing the library directories command formmated
--        for input to the toolset
--   * getLibraries(libs: table) - Returns a string containing the library linking command formatted
--        for input to the toolset
--   * mapFlag(flag: string, value: string or table, version: string (optional)) - Returns a string
--        containing the premake field and value mapped to a toolset command flag.  If the version argument
--        is provided, the toolset will attempt to search for the mapping specific to that toolset.
--        If the version provided could not be resolved or the specific version of the toolset fails
--        to resolve the field and value, it falls back on the base version of the toolset.  If the
--        mapping fails, this returns nil.  Empty strings returned are valid (i.e. field is valid,
--        but there is no mapping for that specific value).
---

local Array = require('array')
local Field = require('field')

local toolset = {}

local _registeredToolsets = {}


---
-- Registers a new tool for usage in premake scripts.
--
-- @param name
--    Name of the tool to allow lookup
-- @param ts
--    Toolset object to associate with the name
---
function toolset.register(name, ts)
    local toolsetField = Field.get('toolset')
    toolsetField.allowed = Array.append(toolsetField.allowed or {}, name)
    _registeredToolsets[name] = ts
end


---
-- Tries to fetch the toolset with the given name.
--
-- @param name
--    Name of the toolset to fetch
-- @returns
--    Toolset object associated with the provided name is one exists, else nil
---
function toolset.try_get(name)
    return _registeredToolsets[name]
end


---
-- Gets the toolset with the given name.  If no such toolset exists, an error is raised.
--
-- @param name
--    Name of the toolset to fetch
-- @returns
--    Toolset object associated with the provided name
---
function toolset.get(name)
    local ts = toolset.try_get(name)
    if not ts then
        error(string.format('No such toolset `%s`', name), 2)
    end
    return ts
end

return toolset