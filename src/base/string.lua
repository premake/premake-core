--
-- string.lua
-- Additions to Lua's built-in string functions.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--


--
-- Capitalize the first letter of the string.
--

	function string.capitalized(self)
		return self:gsub("^%l", string.upper)
	end



--
-- Returns true if the string has a match for the plain specified pattern
--

	function string.contains(s, match)
		return string.find(s, match, 1, true) ~= nil
	end


--
-- Returns an array of strings, each of which is a substring of s
-- formed by splitting on boundaries formed by `pattern`.
--

	function string.explode(s, pattern, plain, maxTokens)
		if (pattern == '') then return false end
		local pos = 0
		local arr = { }
		for st,sp in function() return s:find(pattern, pos, plain) end do
			table.insert(arr, s:sub(pos, st-1))
			pos = sp + 1
			if maxTokens ~= nil and maxTokens > 0 then
				maxTokens = maxTokens - 1
				if maxTokens == 0 then
					break
				end
			end
		end
		table.insert(arr, s:sub(pos))
		return arr
	end



--
-- Find the last instance of a pattern in a string.
--

	function string.findlast(s, pattern, plain)
		local curr = 0
		repeat
			local next = s:find(pattern, curr + 1, plain)
			if (next) then curr = next end
		until (not next)
		if (curr > 0) then
			return curr
		end
	end



--
-- Returns the number of lines of text contained by the string.
--

	function string.lines(s)
		local trailing, n = s:gsub('.-\n', '')
		if #trailing > 0 then
			n = n + 1
		end
		return n
	end



---
-- Return a plural version of a string.
---

	function string:plural()
		if self:endswith("y") then
			return self:sub(1, #self - 1) .. "ies"
		else
			return self .. "s"
		end
	end
