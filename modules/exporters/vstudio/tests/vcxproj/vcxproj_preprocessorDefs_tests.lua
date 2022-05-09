local premake = require("premake")
local vstudio = require("vstudio")

local vcxproj = vstudio.vcxproj

local VsVcxPreprocessorDefsTests = test.declare('VsVcxPreprocessorDefsTests', 'vcxproj', 'vstudio')


function VsVcxPreprocessorDefsTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }
		project('MyProject', function ()
			fn()
		end)
	end)

	return vcxproj.prepare(vstudio.buildDom(2015)
		.workspaces['MyWorkspace']
		.projects['MyProject'])
end


---
-- If no defines are specified, should be silent.
---

function VsVcxPreprocessorDefsTests.clCompile_onNoValues()
	local prj = _execute(function () end)
	vcxproj.clCompilePreprocessorDefinitions(prj.configs['Debug'])
	test.noOutput()
end


---
-- All values present should be listed.
---

function VsVcxPreprocessorDefsTests.clCompile_onMultipleValues()
	local prj = _execute(function ()
		defines { 'ALPHA', 'BETA' }
	end)
	vcxproj.clCompilePreprocessorDefinitions(prj.configs['Debug'])
	test.capture [[
<PreprocessorDefinitions>ALPHA;BETA;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	]]
end


---
-- May be set at the file level.
---

function VsVcxPreprocessorDefsTests.clCompile_perFile()
	local prj = _execute(function ()
		files { 'hello.cpp' }
		when({ 'files:hello.cpp' }, function ()
			defines('ALPHA')
		end)
	end)

	vcxproj.files(prj)
	test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<PreprocessorDefinitions Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">ALPHA;%(PreprocessorDefinitions)</PreprocessorDefinitions>
		<PreprocessorDefinitions Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">ALPHA;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	</ClCompile>
</ItemGroup>
	]]
end


---
-- For ClCompile, quotes should not be escaped.
---

function VsVcxPreprocessorDefsTests.clCompile_doesNotEscapeQuotes()
	local prj = _execute(function ()
		defines { 'ENTRY_POINT="main"' }
	end)
	vcxproj.clCompilePreprocessorDefinitions(prj.configs['Debug'])
	test.capture [[
<PreprocessorDefinitions>ENTRY_POINT="main";%(PreprocessorDefinitions)</PreprocessorDefinitions>
	]]
end
