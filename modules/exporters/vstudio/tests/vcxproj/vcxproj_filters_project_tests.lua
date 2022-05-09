local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VcVcxFiltersProjTests = test.declare('VcVcxFiltersProjTests', 'vcxproj', 'vstudio')


function VcVcxFiltersProjTests.on2010()
	vstudio.setTargetVersion(2010)
	vcxproj.filters.project()
	test.capture [[
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VcVcxFiltersProjTests.on2012()
	vstudio.setTargetVersion(2012)
	vcxproj.filters.project()
	test.capture [[
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VcVcxFiltersProjTests.on2013()
	vstudio.setTargetVersion(2013)
	vcxproj.filters.project()
	test.capture [[
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VcVcxFiltersProjTests.on2015()
	vstudio.setTargetVersion(2015)
	vcxproj.filters.project()
	test.capture [[
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VcVcxFiltersProjTests.on2019()
	vstudio.setTargetVersion(2019)
	vcxproj.filters.project()
	test.capture [[
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end
