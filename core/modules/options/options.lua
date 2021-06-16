---
-- Command line option handling.
---

local premake = require('premake')

local options = {}

options.KIND_ACTION = 'action'
options.KIND_OPTION = 'option'

local _definitions = {}
local _values = nil


function commandLineOption(definition)
	local ok, err = options.register(definition)
	if not ok then
		error(err, 2)
	end
end


function options.register(definition)
	local ok, err = premake.checkRequired(definition, 'trigger', 'description')
	if not ok then
		return false, err
	end

	-- store it
	_definitions[definition.trigger] = definition

	-- new definition requires option values to be parsed again
	_values = nil

	return true
end


function options.all()
	local i = 0

	return function()
		while i < #_ARGS do
			i = i + 1
			local arg = _ARGS[i]

			local trigger, value = options._splitTriggerFromValueIfPresent(arg)

			if not value then
				local def = options.definitionOf(trigger)
				if def and def.value then
					i = i + 1
					value = _ARGS[i] or def.default
				else
					value = _ARGS[i + 1]
				end
			end

			return trigger, value
		end
	end
end


function options.definitionOf(trigger)
	return _definitions[trigger]
end


function options.each()
	local it = options.all()

	return function()
		local trigger, value = it()
		while trigger do
			local def = options.definitionOf(trigger)
			if def then
				return trigger, value
			end
			trigger, value = it()
		end
	end
end


function options.execute(trigger, value)
	local def = options.definitionOf(trigger)
	if def and def.execute then
		def.execute(value)
	end
end


function options.getDefinitions()
	local result = {}

	for _, def in pairs(_definitions) do
		table.insert(result, def)
	end

	table.sort(result, function(a, b)
		return a.trigger < b.trigger
	end)

	return result
end


function options.getKind(trigger)
	if string.startsWith(trigger, '-') then
		return options.KIND_OPTION
	else
		return options.KIND_ACTION
	end
end


function options.isSet(trigger)
	return (options.valueOf(trigger) ~= nil)
end


function options.validate()
	for trigger, _ in options.all() do
		local def = options.definitionOf(trigger)
		if not def then
			return false, string.format('invalid option "%s"', trigger)
		end
	end
	return true
end


function options.valueOf(trigger)
	if not _values then
		_values = {}
		for trigger, value in options.each() do
			_values[trigger] = value
		end
	end

	local def = options.definitionOf(trigger)
	if def then
		return _values[def.trigger] or def.default
	end
end


---
-- If the arg is of the form "trigger=value", split on the "=" and return
-- the split trigger-value pair.
---
function options._splitTriggerFromValueIfPresent(arg)
	local splitAt = string.find(arg, '=', 1, true)
	if splitAt then
		return string.sub(arg, 1, splitAt - 1), string.sub(arg, splitAt + 1)
	else
		return arg, nil
	end
end


return options
