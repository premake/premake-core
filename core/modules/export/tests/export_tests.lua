local export = require('export')

local ExportTests = test.declare('ExportTests', 'export')


function ExportTests.capture_capturesWrites()
	local result = export.capture(function()
		export.write('message goes here')
	end)
	test.isEqual('message goes here', result)
end


function ExportTests.indent_prependsIndentString()
	local result = export.capture(function()
		export.indent()
		export.write('message goes here')
	end)
	test.isEqual('\tmessage goes here', result)
end
