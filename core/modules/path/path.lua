---
-- File system path handling functions.
---

local path = _PREMAKE.path


---
-- Returns a new string with any Premake pattern tokens (i.e. `*`) expanded to Lua patterns.
--
-- TODO: Just a placeholder at the moment; needs implementation.
-- TODO: Move this to C; gets called a lot.
--
-- @param value
--    The string value which may contain patterns.
-- @returns
--    Two values: the input string with Premake pattern tokens expanded, and a boolean
--    indicating whether or not patterns are present (`true` if so, `false` otherwise),
--    suitable for passing as the `plain` argument to Lua string matching functions.
---

function path.expandWildcards(value)
	return value, true
end


return path
