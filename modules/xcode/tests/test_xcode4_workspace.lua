---
-- xcode/tests/test_xcode4_workspace.lua
-- Validate generation for Xcode workspaces.
-- Author Mihai Sebea
-- Modified by Jess Perkins
-- Copyright (c) 2014-2015 Jess Perkins and the Premake project
---

	local suite = test.declare("xcode4_workspace")
	local p = premake
	local xcode = p.modules.xcode


--
-- Setup
--

	local wks, prj

	function suite.setup()
		_TARGET_OS = "macosx"
		p.action.set('xcode4')
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = test.getWorkspace(wks)
		xcode.generateWorkspace(wks)
	end


--
-- Check the basic structure of a workspace.
--

	function suite.onEmptyWorkspace()
		wks.projects = {}
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
</Workspace>
		]]
	end


	function suite.onDefaultWorkspace()
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
	<FileRef
		location = "group:MyProject.xcodeproj">
	</FileRef>
</Workspace>
		]]
	end


	function suite.onMultipleProjects()
		test.createproject(wks)
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
	<FileRef
		location = "group:MyProject.xcodeproj">
	</FileRef>
	<FileRef
		location = "group:MyProject2.xcodeproj">
	</FileRef>
</Workspace>
		]]
	end

	function suite.onMultipleProjectsGrouped()
		test.createGroup(wks)
		test.createproject(wks)
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
	<Group
		location = "container:"
		name = "MyGroup1">
		<FileRef
			location = "group:MyProject2.xcodeproj">
		</FileRef>
	</Group>
	<FileRef
		location = "group:MyProject.xcodeproj">
	</FileRef>
</Workspace>
		]]
	end



--
-- Projects should include relative path from workspace.
--

	function suite.onNestedProjectPath()
		location "MyProject"
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
	<FileRef
		location = "group:MyProject/MyProject.xcodeproj">
	</FileRef>
</Workspace>
		]]
	end

	function suite.onExternalProjectPath()
		location "../MyProject"
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
	<FileRef
		location = "group:../MyProject/MyProject.xcodeproj">
	</FileRef>
</Workspace>
		]]
	end
