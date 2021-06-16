---
-- System-defined command line options
---

local m = select(1, ...)


commandLineOption {
	trigger = '--file',
	description = string.format('Read FILE as a Premake script; default is "%s"', m.PROJECT_SCRIPT_NAME),
	value = 'FILE',
	default = m.PROJECT_SCRIPT_NAME
}

commandLineOption { -- TODO: Move to help module; use `register()`
	trigger = '--help',
	description = 'Display this information',
	execute = function()
		local help = require('help')
		help.printHelp()
	end
}

commandLineOption {
	trigger = '--scripts',
	description = "Search for additional scripts on the given path",
	value = 'PATH'
}

commandLineOption {
	trigger = '--systemscript',
	description = string.format('Override default system script (%s)', m.SYSTEM_SCRIPT_NAME),
	value = 'FILE',
	default = m.SYSTEM_SCRIPT_NAME
}

commandLineOption {
	trigger = '--verbose',
	description = 'Generate extra debug text output'
}

commandLineOption {
	trigger = '--version',
	description = 'Display version information',
	execute = function()
		print(string.format('Premake Build Script Generator version %s', _PREMAKE.VERSION))
	end
}
