commandLineOption {
	trigger = 'gmake',
	description = 'Generate GNU make files',
	category = 'Exporters',
	execute = function ()
		local gmake = require('gmake')
		gmake.export()
	end
}
