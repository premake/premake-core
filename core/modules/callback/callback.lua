---
-- When a callback function is invoked, the `_SCRIPT` and `_SCRIPT_DIR` are set to the _caller's_ script,
-- rather than the script where the callback function itself was defined. Use this module to wrap the
-- callback and restore those variables when it is invoked to get the expected behavior.
--
-- If you'd rather _not_ restore those variables, just invoke the callback function as you normally would,
-- and don't use this module to wrap it.
---

local Callback = {}

-- Allow Callback instances to be used as functions
local metatable = {
	__call = function(callback, ...)
		return Callback.call(callback, ...)
	end
}


function Callback.new(fn)
	return setmetatable({
		_fn = fn,
		_SCRIPT = _SCRIPT,
		_SCRIPT_DIR = _SCRIPT_DIR
	}, metatable)
end


function Callback.call(self, ...)
	local fn = self._fn
	if fn ~= nil then
		local script = _SCRIPT
		local scriptDir = _SCRIPT_DIR

		_SCRIPT = self._SCRIPT
		_SCRIPT_DIR = self._SCRIPT_DIR

		local a, b, c, d, e, f = fn(...)

		_SCRIPT = script
		_SCRIPT_DIR = scriptDir

		return a, b, c, d, e, f
	end
end


return Callback
