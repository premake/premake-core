commandLineOption {
	trigger = '--help',
	description = 'Display this information',
	execute = function()
		local help = require('help')
		help.printHelp()
	end
}