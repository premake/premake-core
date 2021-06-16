local Field = require('field')
local premake = require('premake')
local Store = require('store')

local scripting = {}

local _store = premake.store()


local function _addField(field)
	_G[field.name] = function(...)
		Store.addValue(_store, field, ...)
	end

	 _G['remove' .. string.capitalize(field.name)] = function(...)
		Store.removeValue(_store, field, ...)
	end
end


local function _removeField(field)
	_G[field.name] = nil
	_G['remove' .. string.capitalize(field.name)] = nil
end


-- Watch for field changes, and update scripting API accordingly

Field.onFieldAdded(function(field)
	_addField(field)
end)

Field.onFieldRemoved(function(field)
	_removeField(field)
end)


-- Add all currently registered fields to the scripting API

for field in Field.each() do
	_addField(field)
end


-- Add convenience functions

function when(clauses, fn)
	Store.pushCondition(_store, clauses)
	if fn ~= nil then
		fn()
	end
	Store.popCondition(_store)
end


function project(name, fn)
	projects(name)
	when({ projects = name }, function()
		baseDir(_SCRIPT_DIR)
		if fn ~= nil then
			fn()
		end
	end)
end


function workspace(name, fn)
	workspaces(name)
	when({ workspaces = name }, function()
		baseDir(_SCRIPT_DIR)
		if fn ~= nil then
			fn()
		end
	end)
end


return scripting
