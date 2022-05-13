---
-- Base GCC flag mapper.
---

local base = {}

base.mappings = {
    rtti = {
        On = '',
        Off = '-fno-rtti',
        Default = ''
    }
}

---
-- Maps a premake flag and value to a GCC compiler flag
--
-- @param flag
--    Premake field name
-- @param value
--    Value of the field
-- @returns
--    GCC compiler flag if mapping could be made, else nil
---
function base.mapFlag(flag, value)
    local mapping = base.mappings[flag]
    if mapping then
        return mapping[value]
    end
    return nil
end

return base