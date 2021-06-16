---
-- Overrides and extensions to Lua's `os` library.
---

local path = require('path')


function os.matchDirs(mask)
	local result = {}
	os._match(result, mask, 'dir')
	return result
end


function os.matchFiles(mask)
	local result = {}
	os._match(result, mask, 'file')
	return result
end


function os._match(results, mask, type)
	mask = path.normalize(mask)

	-- The native code matching calls only support wildcards at the end of the path, and
	-- the don't support the recursion operator ('**') at all. So we need to split the path
	-- up and test each wildcard component in turn. Start by finding the first component
	-- which contains a wildcard pattern...

	local indexOfWildcard = string.find(mask, '*', 1, true)

	-- Split the path up around that component
	local directory, pattern, remainder

	if indexOfWildcard ~= nil then
		local indexOfSlash = string.find(mask, '/', indexOfWildcard, true)
		if indexOfSlash ~= nil then
			remainder = mask:sub(indexOfSlash + 1)
			mask = mask:sub(1, indexOfSlash - 1)
		end
	end

	directory = path.getDirectory(mask)
	pattern = path.getName(mask)

	-- Convert patterns like '**.txt' to '**/*.txt'
	if string.startsWith(pattern, '**') then
		if #pattern > 2 then
			remainder = (remainder or '') .. '*' .. string.sub(pattern, 3)
			pattern = '**'
		end
	end

	-- Define an iterator to walk over matches
	local function matches(directory, pattern)
		local matcher = os.matchStart(directory, pattern)
		return function()
			local next = os.matchNext(matcher)
			if next then
				local matched = path.join(directory, os.matchName(matcher))
				if os.isFile(matched) then
					return matched, 'file'
				else
					return matched, 'dir'
				end
			end
			os.matchDone(matcher)
		end
	end

	-- If the mask continues into subfolders, look at those first
	if remainder and pattern == '**' then
		os._match(results, path.join(directory, remainder), type)
	end

	-- Now look for matches at this level
	for matched, matchType in matches(directory, pattern) do
		-- if `pattern` occurs at the end of the mask, add matches to the results
		if not remainder and matchType == type then
			table.insert(results, matched)
		end

		-- recurse into subdirs, looking for the rest of the mask
		if matchType == 'dir' then
			if pattern == '**' then
				os._match(results, path.join(matched, '**', remainder), type)
			elseif remainder then
				os._match(results, path.join(matched, remainder), type)
			end
		end
	end
end


return os
