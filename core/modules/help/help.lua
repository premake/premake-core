---
-- The Premake help text module.
--
-- Prints the help text shown when the `--help` option is specified on the command line.
---

local help = {}

local options = require('options')
local path = require('path')


function help.printHelp()
	-- display the basic usage
	printf("Premake %s, a build script generator", _PREMAKE.VERSION)
	printf(_PREMAKE.COPYRIGHT)
	printf('%s %s', _VERSION, _COPYRIGHT)
	printf()
	printf('Usage: %s [options] action...', path.getName(_ARGS[0]))
	printf()

	local definitions = options.getDefinitions()

	local categories = help._collectCategories(definitions)

	-- print out the options first, sorted by category
	for i = 1, #categories do
		local cat = categories[i]
		local items = help._collectItems(definitions, options.KIND_OPTION, cat)
		if #items > 0 then
			help._printItems(items, 'OPTIONS', cat)
			print()
		end
	end

	-- then actions, sorted by category
	for i = 1, #categories do
		local cat = categories[i]
		local items = help._collectItems(definitions, options.KIND_ACTION, cat)
		if #items > 0 then
			help._printItems(items, 'ACTIONS', cat)
			print()
		end
	end

	printf('For additional information, see %s', _PREMAKE.WEBSITE)
end


function help._collectCategories(definitions)
	local categories = {}

	for i = 1, #definitions do
		local def = definitions[i]
		local cat = def.category or ''

		if not categories[cat] then
			categories[cat] = cat
			table.insert(categories, cat)
		end
	end

	table.sort(categories)
	return categories
end


function help._collectItems(definitions, kind, category)
	local items = {}

	for i = 1, #definitions do
		local def = definitions[i]
		local cat = def.category or ''
		if options.getKind(def.trigger) == kind and cat == category then
			table.insert(items, def)
		end
	end

	table.sort(items, function(a, b)
		return a.trigger < b.trigger
	end)

	return items
end


function help._printItems(items, kind, category)
	if category == '' then
		category = 'General'
	end

	printf('%s - %s', kind, category)
	printf()

	local maxLabelLen = 0
	for i = 1, #items do
		local item = items[i]
		local len = #item.trigger + #(item.value or '') + 2
		if len > maxLabelLen then
			maxLabelLen = len
		end
	end

	local format = ' %-' .. maxLabelLen .. 's %s'

	for i = 1, #items do
		local item = items[i]

		local label = item.trigger
		local description = item.description

		if item.value then
			label = string.format("%s %s", label, item.value)
		end

		if item.allowedValues then
			description = string.format('%s; one of:', description)
		end

		printf(format, label, description)

		if item.allowedValues then
			table.sort(item.allowedValues, function(a, b)
				return a[1] < b[1]
			end)

			local format = '     %-' .. (maxLabelLen - 3) .. 's %s'

			for j = 1, #item.allowedValues do
				local value = item.allowedValues[j]
				printf(format, value[1], value[2])
			end
		end
	end
end


return help
