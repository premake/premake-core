local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxProjectTests = test.declare('VsVcxProjectTests', 'vcxproj', 'vstudio')


function VsVcxProjectTests.on2010()
	vstudio.setTargetVersion(2010)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VsVcxProjectTests.on2012()
	vstudio.setTargetVersion(2012)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VsVcxProjectTests.on2013()
	vstudio.setTargetVersion(2013)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" ToolsVersion="12.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VsVcxProjectTests.on2015()
	vstudio.setTargetVersion(2015)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" ToolsVersion="14.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VsVcxProjectTests.on2017()
	vstudio.setTargetVersion(2017)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end


function VsVcxProjectTests.on2019()
	vstudio.setTargetVersion(2019)
	vcxproj.project()
	test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	]]
end
