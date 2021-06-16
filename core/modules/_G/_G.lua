---
-- Extensions to Lua's global functions.
---

local path = _PREMAKE.path
local premake = _PREMAKE.premake

local Callback = require('callback')

package.registered = {}

local _onRequireCallbacks = {}


function doFile(filename, ...)
	local chunk, err = loadFile(filename)
	if err then
		error(err, 2)
	end
	return (chunk(...))
end


function doFileOpt(filename, ...)
	local chunk, err = loadFileOpt(filename);
	if err then
		error(err, 2)
	end
	if chunk then
		return (chunk(...))
	end
end


function onRequire(moduleName, fn)
	local callbacks = _onRequireCallbacks[moduleName] or {}
	table.insert(callbacks, Callback.new(fn))
	_onRequireCallbacks[moduleName] = callbacks
end


function printf(msg, ...)
	print(string.format(msg or '', ...))
end


function register(module)
	local ok, err = tryRegister(module)
	if not ok then
		error(err, 2)
	end
end


local _builtInRequire = require

function require(moduleName)
	local module = _builtInRequire(moduleName)

	local callbacks = _onRequireCallbacks[moduleName] or _EMPTY
	for i = 1, #callbacks do
		Callback.call(callbacks[i], module)
	end

	return module
end


function tryRegister(module)
	if package.registered[module] then
		return true
	end

	local location = premake.locateModule(module)
	if not location then
		return false, string.format('Module `%s` not found', module)
	end

	local scriptPath = path.join(path.getDirectory(location), '_register.lua')
	doFileOpt(scriptPath)

	package.registered[module] = scriptPath;
	return true
end


return _G
