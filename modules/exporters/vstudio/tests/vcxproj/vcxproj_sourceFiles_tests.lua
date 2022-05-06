local premake = require("premake")
local vstudio = require("vstudio")

local vcxproj = vstudio.vcxproj

local VsVcxSourceFileTests = test.declare('VsVcxSourceFileTests', 'vcxproj', 'vstudio')


function VsVcxSourceFileTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.files(prj)
end


---
-- Should be able to handle a project with no files.
---

function VsVcxSourceFileTests.emptyItemGroup_onNoFiles()
	_execute(function () end)
	test.noOutput()
end


---
-- Check categorization of different file types
---

function VsVcxSourceFileTests.onClCompileFiles()
	_execute(function ()
		files {
			'File.c',
			'File.cc',
			'File.cpp',
			'File.cxx',
			'File.c++',
			'File.m',
			'File.mm'
		}
	end)
	test.capture [[
<ItemGroup>
	<ClCompile Include="File.c" />
	<ClCompile Include="File.cc" />
	<ClCompile Include="File.cpp" />
	<ClCompile Include="File.cxx" />
	<ClCompile Include="File.c++" />
	<ClCompile Include="File.m" />
	<ClCompile Include="File.mm" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onClIncludeFiles()
	_execute(function ()
		files {
			'File.h',
			'File.hh',
			'File.hpp',
			'File.hxx',
			'File.inl'
		}
	end)
	test.capture [[
<ItemGroup>
	<ClInclude Include="File.h" />
	<ClInclude Include="File.hh" />
	<ClInclude Include="File.hpp" />
	<ClInclude Include="File.hxx" />
	<ClInclude Include="File.inl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onFxCompileFiles()
	_execute(function ()
		files {
			'File.hlsl'
		}
	end)
	test.capture [[
<ItemGroup>
	<FxCompile Include="File.hlsl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onImageFiles()
	_execute(function ()
		files {
			'File.gif',
			'File2.jpg',
			'File3.jpe',
			'File4.png',
			'File5.bmp',
			'File6.dib',
			'File7.tif',
			'File8.wmf',
			'File9.ras',
			'File0.eps',
			'File1.pcx',
			'File2.pcd',
			'File3.tga',
			'File4.dds'
	}
	end)
	test.capture [[
<ItemGroup>
	<Image Include="File.gif" />
	<Image Include="File2.jpg" />
	<Image Include="File3.jpe" />
	<Image Include="File4.png" />
	<Image Include="File5.bmp" />
	<Image Include="File6.dib" />
	<Image Include="File7.tif" />
	<Image Include="File8.wmf" />
	<Image Include="File9.ras" />
	<Image Include="File0.eps" />
	<Image Include="File1.pcx" />
	<Image Include="File2.pcd" />
	<Image Include="File3.tga" />
	<Image Include="File4.dds" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onMidlFiles()
	_execute(function ()
		files {
			'File.idl'
		}
	end)
	test.capture [[
<ItemGroup>
	<Midl Include="File.idl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onNatvisFiles()
	_execute(function ()
		files {
			'File.natvis'
		}
	end)
	test.capture [[
<ItemGroup>
	<Natvis Include="File.natvis" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onResourceCompileFiles()
	_execute(function ()
		files {
			'File.rc'
		}
	end)
	test.capture [[
<ItemGroup>
	<ResourceCompile Include="File.rc" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onMasmFiles()
	_execute(function ()
		files {
			'File.asm',
			'File.s'
		}
	end)
	test.capture [[
<ItemGroup>
	<Masm Include="File.asm" />
	<Masm Include="File.s" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.onOtherFileTypes()
	_execute(function ()
		files {
			'File',
			'File.md',
			'File.txt'
		}
	end)
	test.capture [[
<ItemGroup>
	<None Include="File" />
	<None Include="File.md" />
	<None Include="File.txt" />
</ItemGroup>
	]]
end


---
-- Files use project-relative paths, with backspace separators.
---

function VsVcxSourceFileTests.pathsAreProjectRelativeAndTranslated()
	_execute(function ()
		location "Build"
		files { 'Docs/Hello.txt' }
	end)
	test.capture [[
<ItemGroup>
	<None Include="..\Docs\Hello.txt" />
</ItemGroup>
	]]
end


---
-- Files that are only listed in a subset of the configurations should be excluded
-- from all other configurations.
---

function VsVcxSourceFileTests.clCompile_excludedFromBuild()
	_execute(function ()
		when({ 'configurations:Debug' }, function ()
			files { 'Hello.cpp' }
		end)
	end)
	test.capture [[
<ItemGroup>
	<ClCompile Include="Hello.cpp">
		<ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">true</ExcludedFromBuild>
	</ClCompile>
</ItemGroup>
	]]
end
