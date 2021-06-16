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

	local prj = vcxproj.prepare(vstudio.fetch(2015).workspaces['MyWorkspace'].projects['MyProject'])
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
-- Check categorization of main file types.
---

function VsVcxSourceFileTests.useNone_onNotOtherwiseCategorized()
	_execute(function ()
		files { 'LICENSE', 'README.txt' }
	end)
	test.capture [[
<ItemGroup>
	<None Include="LICENSE" />
	<None Include="README.txt" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useClInclude_onHeaderFiles()
	_execute(function ()
		files { 'File1.h', 'File2.hh', 'File3.hpp', 'File4.hxx', 'File5.inl'  }
	end)
	test.capture [[
<ItemGroup>
	<ClInclude Include="File1.h" />
	<ClInclude Include="File2.hh" />
	<ClInclude Include="File3.hpp" />
	<ClInclude Include="File4.hxx" />
	<ClInclude Include="File5.inl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useClCompile_onHeaderFiles()
	_execute(function ()
		files { 'File1.cc', 'File2.cpp', 'File3.cxx', 'File4.c++', 'File5.c', 'File6.s', 'File7.m', 'File8.mm'  }
	end)
	test.capture [[
<ItemGroup>
	<ClCompile Include="File1.cc" />
	<ClCompile Include="File2.cpp" />
	<ClCompile Include="File3.cxx" />
	<ClCompile Include="File4.c++" />
	<ClCompile Include="File5.c" />
	<ClCompile Include="File6.s" />
	<ClCompile Include="File7.m" />
	<ClCompile Include="File8.mm" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useFxCompile_onHlslFile()
	_execute(function ()
		files { 'File1.hlsl'  }
	end)
	test.capture [[
<ItemGroup>
	<FxCompile Include="File1.hlsl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useResourceCompile_onRcFile()
	_execute(function ()
		files { 'File1.rc'  }
	end)
	test.capture [[
<ItemGroup>
	<ResourceCompile Include="File1.rc" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useMidl_onIdlFile()
	_execute(function ()
		files { 'File1.idl'  }
	end)
	test.capture [[
<ItemGroup>
	<Midl Include="File1.idl" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useMasm_onAsmFile()
	_execute(function ()
		files { 'File1.asm'  }
	end)
	test.capture [[
<ItemGroup>
	<Masm Include="File1.asm" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useImage_onImgFile()
	_execute(function ()
		files { 'File1.gif', 'File2.jpg', 'File3.jpe', 'File4.png', 'File5.bmp', 'File6.dib', 'File7.tif', 'File8.wmf', 'File9.ras', 'File10.eps', 'File11.pcx', 'File12.pcd', 'File13.tga', 'File14.dds' }
	end)
	test.capture [[
<ItemGroup>
	<Image Include="File1.gif" />
	<Image Include="File2.jpg" />
	<Image Include="File3.jpe" />
	<Image Include="File4.png" />
	<Image Include="File5.bmp" />
	<Image Include="File6.dib" />
	<Image Include="File7.tif" />
	<Image Include="File8.wmf" />
	<Image Include="File9.ras" />
	<Image Include="File10.eps" />
	<Image Include="File11.pcx" />
	<Image Include="File12.pcd" />
	<Image Include="File13.tga" />
	<Image Include="File14.dds" />
</ItemGroup>
	]]
end


function VsVcxSourceFileTests.useNatvis_onImgFile()
	_execute(function ()
		files { 'File1.natvis' }
	end)
	test.capture [[
<ItemGroup>
	<Natvis Include="File1.natvis" />
</ItemGroup>
	]]
end



-- TODO: each category should appear in its own <ItemGroup/>

---
-- Files use project-relative paths, with backspace separators.
---

function VsVcxSourceFileTests.pathsAreProjectRelativeAndTranslated()
	_execute(function ()
		files { 'Docs/Hello.txt' }

		-- TODO: Add a location to offset the path

	end)
	test.capture [[
<ItemGroup>
	<None Include="Docs\Hello.txt" />
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
