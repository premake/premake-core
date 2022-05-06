commandLineOption {
	trigger = 'xcode',
	description = 'Generate Xcode project files',
	category = 'Exporters',
	execute = function ()
		local xcode = require('xcode')
		xcode.export()
	end
}
