commandLineOption {
	trigger = 'vstudio',
	value = '[version]',
	default = '2019',
	description = 'Generate Visual Studio project files',
	category = 'Exporters',
	execute = function (version)
		local vstudio = require('vstudio')
		vstudio.export(version)
	end
}
