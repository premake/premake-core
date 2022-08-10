local premake = require("premake")
local vstudio = require("vstudio")

local vcxproj = vstudio.vcxproj

local VsVcxIncludeDirTests = test.declare('VsVcxIncludeDirTests', 'vcxproj', 'vstudio')


function VsVcxIncludeDirTests.setup()
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
-- If no include directories are specified, should be silent.
---

function VsVcxIncludeDirTests.clCompile_onNoValues()
	local prj = _execute(function () end)
	vcxproj.clCompileAdditionalIncludeDirectories(prj.configs['Debug'])
	test.noOutput()
end


---
-- All values present should be listed.
---

function VsVcxIncludeDirTests.clCompile_onMultipleValues()
	local prj = _execute(function ()
		includeDirs { 'include/lua', 'include/zlib' }
	end)
	vcxproj.clCompileAdditionalIncludeDirectories(prj.configs['Debug'])
	test.capture [[
<AdditionalIncludeDirectories>include\lua;include\zlib;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
	]]
end


---
-- Paths should be made project relative.
---

function VsVcxIncludeDirTests.clCompile_makesProjectRelative()
	local prj = _execute(function ()
		location 'build'
		includeDirs { 'include/lua', 'include/zlib' }
	end)
	vcxproj.clCompileAdditionalIncludeDirectories(prj.configs['Debug'])
	test.capture [[
<AdditionalIncludeDirectories>..\include\lua;..\include\zlib;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
	]]
end


---
-- May be set at the file level.
---

function VsVcxIncludeDirTests.clCompile_perFile()
	local prj = _execute(function ()
		files { 'hello.cpp' }
		when({ 'files:hello.cpp' }, function ()
			includeDirs('include/hello')
		end)
	end)

	vcxproj.files(prj)
	test.capture [[
<ItemGroup>
	<ClCompile Include="hello.cpp">
		<AdditionalIncludeDirectories Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">include\hello;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
		<AdditionalIncludeDirectories Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">include\hello;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
	</ClCompile>
</ItemGroup>
	]]
end


---
-- Inherit public paths from projectLinks.
---

function VsVcxIncludeDirTests.clCompile_inheritsPublicPathsFromProjectLinksRecursively()
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }

		project('MyProject', function ()
			includeDirs { 'include/lua', 'include/zlib' }
			projectLinks { 'MyLib1' }
		end)

		project('MyLib1', function ()
			projectLinks { 'MyLib2' }
			includeDirs {
				public = {
					'mylib1/public',
				},
				private = {
					'mylib1/private',
				},
			}
		end)

		project('MyLib2', function ()
			includeDirs {
				public = {
					'mylib2/public',
				},
				private = {
					'mylib2/private',
				},
			}
		end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015)
		.workspaces['MyWorkspace']
		.projects['MyProject'])

	vcxproj.clCompileAdditionalIncludeDirectories(prj.configs['Debug'])
	test.capture [[
<AdditionalIncludeDirectories>include\lua;include\zlib;mylib1\public;mylib2\public;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
	]]
end
