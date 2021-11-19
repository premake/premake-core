local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjObjectsTests = test.declare('GmakeProjObjectsTests', 'gmake-proj', 'gmake')


---
-- Tests the output of the object list with no objects.
---
function GmakeProjObjectsTests.NoObject()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.objects(prj)

	test.capture [[
OBJECTS :=
	]]
end


---
-- Tests the output of the objects list with a single object.
---
function GmakeProjObjectsTests.SingleObject()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			files({
				'file.c'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.objects(prj)

	test.capture [[
OBJECTS :=

OBJECTS += $(OBJDIR)/file.o
	]]
end


---
-- Tests the output of the objects list with multiple objects.
---
function GmakeProjObjectsTests.MultipleObjects()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			files({
				'file.c',
				'other.c'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.objects(prj)

	test.capture [[
OBJECTS :=

OBJECTS += $(OBJDIR)/file.o
OBJECTS += $(OBJDIR)/other.o
	]]
end