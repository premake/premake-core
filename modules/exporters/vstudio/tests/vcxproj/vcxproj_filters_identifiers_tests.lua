local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VcVcxFiltersIdentifiersTests = test.declare('VcVcxFiltersIdentifiersTests', 'vcxproj', 'vstudio')


function VcVcxFiltersIdentifiersTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.filters.identifiers(prj)
end


---
-- Files in the root folder (the same one as the project) don't get identifiers.
---

function VcVcxFiltersIdentifiersTests.noIdentifier_onRootFile()
	_execute(function ()
		files { "hello.c", "goodbye.c" }
	end)
	test.noOutput()
end


---
-- Folders shared between multiple files should be reduced to a single identifier.
---

function VcVcxFiltersIdentifiersTests.emitsOneIdentifier_onMultipleFiles()
	_execute(function ()
		files { "src/hello.c", "src/goodbye.c", "so_long.h" }
	end)
	test.capture [[
<ItemGroup>
	<Filter Include="src">
		<UniqueIdentifier>{2DAB880B-99B4-887C-2230-9F7C8E38947C}</UniqueIdentifier>
	</Filter>
</ItemGroup>
	]]
end


---
-- Nested folders should each get their own unique identifier.
---

function VcVcxFiltersIdentifiersTests.emitsMultipleIdentifiers_onNestedFolders()
	_execute(function ()
		files { "src/greetings/hello.c", "src/departures/goodbye.c", "src/so_long.h" }
	end)
	test.capture [[
<ItemGroup>
	<Filter Include="src">
		<UniqueIdentifier>{2DAB880B-99B4-887C-2230-9F7C8E38947C}</UniqueIdentifier>
	</Filter>
	<Filter Include="src\departures">
		<UniqueIdentifier>{BB36ED8F-A704-E195-9098-51BC7C05BDFA}</UniqueIdentifier>
	</Filter>
	<Filter Include="src\greetings">
		<UniqueIdentifier>{A4BFFA97-1080-76CE-D9BA-BF4B453ABBAA}</UniqueIdentifier>
	</Filter>
</ItemGroup>
	]]
end
