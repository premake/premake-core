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

	local sln, prj

	function suite.setup()
		_ACTION = "xcode4"
		sln = test.createsolution()
	end

	local function prepare()
		sln = test.getsolution(sln)
		xcode.generateWorkspace(sln)
	end


--
-- Check the basic structure of a workspace.
--

	function suite.onEmptySolution()
		sln.projects = {}
		prepare()
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
	version = "1.0">
</Workspace>
		]]
	end


	function suite.onDefaultSolution()
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
		test.createproject(sln)
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
