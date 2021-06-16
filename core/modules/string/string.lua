---
-- Overrides and extensions to Lua's `string` library.
---

---
-- Converts first letter of string to uppercase if it isn't already.
---

function string.capitalize(self)
	return (string.gsub(self, '^%l', string.upper))
end


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

function string.expandWildcards(value)
	return value, true
end


---
-- Find the last occurrence of a pattern in a string.
---

function string.findLast(self, pattern, plain)
	local i = 0

	repeat
		local next = string.find(self, pattern, i + 1, plain)
		if next then
			i = next
		end
	until (not next)

	if i > 0 then
		return i
	end
end


---
-- Split a string on each occurrence of a pattern, up to `limit` times.
--
-- @returns
--    An array of string results.
---

function string.split(self, pattern, plain, limit)
	local result = {}

	local pos = 0
	local count = 0

	local iter = function()
		return string.find(self, pattern, pos, plain)
	end

	for start, stop in iter do
		table.insert(result, string.sub(self, pos, start - 1))
		pos = stop + 1
		count = count + 1
		if limit ~= nil and count == limit then
			break
		end
	end

	table.insert(result, string.sub(self, pos))
	return result
end


---
-- Splits the string at the provided pattern, and returns two results: the
-- string before the split, and the one after.
--
-- @returns
--    Two values: the string before the pattern, and the string after.
---

function string.splitOnce(self, pattern, plain)
	local start, stop = string.find(self, pattern, pos, plain)
	if start == nil then
		return self
	else
		return string.sub(self, 1, start - 1), string.sub(self, stop + 1)
	end
end


return string
