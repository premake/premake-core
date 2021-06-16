---
-- Premake script-side program entry point.
---

_EMPTY = setmetatable({}, {
	__newindex = function ()
		error('attempted to modify `_EMPTY`')
	end
})

forceRequire('_G')
forceRequire('string')
forceRequire('table')
forceRequire('os')
forceRequire('io')

local main = require('main')

function _premake_main()
	main.run()
end
