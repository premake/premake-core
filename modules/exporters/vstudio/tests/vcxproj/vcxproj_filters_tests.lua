local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VcVcxFiltersTests = test.declare('VcVcxFiltersTests', 'vcxproj', 'vstudio')


function VcVcxFiltersTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.filters.filters(prj)
end


---
-- Files at the root of the project, with no path information, should not specify any filter.
---

function VcVcxFiltersTests.filters_onNoPath()
	_execute(function ()
		files { 'hello.h' }
	end)
	test.capture [[
<ItemGroup>
	<ClInclude Include="hello.h" />
</ItemGroup>
	]]
end


---
-- Files located in a subfolder should specify the parent folder as the filter.
---

function VcVcxFiltersTests.filters_onNestedFolders()
	_execute(function ()
		files { 'src/greetings/hello.h' }
	end)
	test.capture [[
<ItemGroup>
	<ClInclude Include="src\greetings\hello.h">
		<Filter>src\greetings</Filter>
	</ClInclude>
</ItemGroup>
	]]
end
