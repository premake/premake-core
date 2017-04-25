--
-- tests/api/test_containers.lua
-- Tests the API's workspace() and project() container definitions.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_containers")
	local api = p.api


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		wks = workspace("MyWorkspace")
	end


--
-- The first time a name is encountered, a new container should be created.
--

	function suite.workspace_createsOnFirstUse()
		test.isnotnil(p.global.getWorkspace("MyWorkspace"))
	end

	function suite.project_createsOnFirstUse()
		project("MyProject")
		test.isnotnil(test.getproject(wks, "MyProject"))
	end


--
-- When a container is created, it should become the active scope.
--

	function suite.workspace_setsActiveScope()
		test.issame(api.scope.workspace, wks)
	end

	function suite.project_setsActiveScope()
		local prj = project("MyProject")
		test.issame(api.scope.project, prj)
	end


--
-- When container function is called with no arguments, that should
-- become the current scope.
--

	function suite.workspace_setsActiveScope_onNoArgs()
		project("MyProject")
		group("MyGroup")
		workspace()
		test.issame(wks, api.scope.workspace)
		test.isnil(api.scope.project)
		test.isnil(api.scope.group)
	end

	function suite.project_setsActiveScope_onNoArgs()
		local prj = project("MyProject")
		group("MyGroup")
		project()
		test.issame(prj, api.scope.project)
	end


--
-- The "*" name should activate the parent scope.
--

	function suite.workspace_onStar()
		project("MyProject")
		group("MyGroup")
		filter("Debug")
		workspace("*")
		test.isnil(api.scope.workspace)
		test.isnil(api.scope.project)
		test.isnil(api.scope.group)
	end

	function suite.project_onStar()
		project("MyProject")
		group("MyGroup")
		filter("Debug")
		project "*"
		test.issame(wks, api.scope.workspace)
		test.isnil(api.scope.project)
	end
