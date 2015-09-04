---
-- xcode/tests/test_xcode4_workspace.lua
-- Validate generation for Xcode workspaces.
-- Author Mihai Sebea
-- Modified by Jason Perkins
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
---

	local suite = test.declare("xcode4_workspace")
	local xcode = premake.modules.xcode


--
-- Setup
--

	local wks, prj

	function suite.setup()
		_ACTION = "xcode4"
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
