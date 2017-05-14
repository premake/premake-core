local p = premake
p.raw = { }
local raw = p.raw
local gvisited = { }

function raw.solution(sln)
	if not gvisited[sln.global] then
		gvisited[sln.global] = true
		raw.printTable({ global = sln.global })
	end
end

function raw.printTable(t, i)
	i = i or 0
	placement = raw._createPlacement(t)
	raw._printTableRecursive(t, i, placement)
end

function raw._printTableRecursive(t, i, placement)
	elements = { }
	for k, v in pairs(t) do
		table.insert(elements, { key = k, value = v })
	end

	table.sort(elements, function(a, b)
		local n1 = type(a.key) == "number"
		local n2 = type(b.key) == "number"
		if n1 ~= n2 then
			return n1
		end

		local k1 = n1 and a.key or raw._encode(a.key)
		local k2 = n2 and b.key or raw._encode(b.key)
		return k1 < k2
	end)

	for _, elem in ipairs(elements) do
		p = placement[elem.value]
		if p and elem.key == p.key and t == p.parent then
			_p(i, "%s", raw._encode(elem.key) .. ': ' .. raw._encode(elem.value) .. ' {')
			raw._printTableRecursive(elem.value, i + 1, placement)
			_p(i, '} # ' .. raw._encode(elem.key))
		else
			_p(i, "%s", raw._encode(elem.key) .. ': ' .. raw._encode(elem.value))
		end
	end
end

function raw._createPlacement(tbl)
	placement = { }
	placementList = { tbl }
	while #placementList ~= 0 do
		parentList = { }
		for _, parent in ipairs(placementList) do
			for k, v in pairs(parent) do
				if type(v) == "table" and not placement[v] then
					table.insert(parentList, v)
					placement[v] = {
						parent = parent,
						key = k
					}
				end
			end
		end
		placementList = parentList
	end
	return placement
end

function raw._encode(v)
	if type(v) == "string" then
		return '"' .. v .. '"'
	else
		return tostring(v)
	end
end
