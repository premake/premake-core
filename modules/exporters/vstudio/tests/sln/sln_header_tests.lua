local vstudio = require('vstudio')
local sln = vstudio.sln

local VsSlnHeaderTests = test.declare('VsSlnHeaderTests', 'vstudio-sln', 'vstudio')


function VsSlnHeaderTests.on2010()
	vstudio.setTargetVersion(2010)

	sln.header()

	test.capture [[
Microsoft Visual Studio Solution File, Format Version 11.00
# Visual Studio 2010
	]]
end


function VsSlnHeaderTests.on2012()
	vstudio.setTargetVersion(2012)

	sln.header()

	test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2012
	]]
end


function VsSlnHeaderTests.on2015()
	vstudio.setTargetVersion(2015)

	sln.header()

	test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 14
	]]
end


function VsSlnHeaderTests.on2017()
	vstudio.setTargetVersion(2017)

	sln.header()

	test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 15
	]]
end


function VsSlnHeaderTests.on2019()
	vstudio.setTargetVersion(2019)

	sln.header()

	test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 16
	]]
end
