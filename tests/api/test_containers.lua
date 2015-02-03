--
-- tests/api/test_containers.lua
-- Tests the API's solution() and project() container definitions.
-- Copyright (c) 2013-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("api_containers")
	local api = premake.api


--
-- Setup and teardown
--

	local sln

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- The first time a name is encountered, a new container should be created.
--

	function suite.solution_createsOnFirstUse()
		test.isnotnil(premake.global.getSolution("MySolution"))
	end

	function suite.project_createsOnFirstUse()
		project("MyProject")
		test.isnotnil(premake.solution.getproject(sln, "MyProject"))
	end


--
-- When a container is created, it should become the active scope.
--

	function suite.solution_setsActiveScope()
		test.issame(api.scope.solution, sln)
	end

	function suite.project_setsActiveScope()
		local prj = project("MyProject")
		test.issame(api.scope.project, prj)
	end


--
-- When container function is called with no arguments, that should
-- become the current scope.
--

	function suite.solution_setsActiveScope_onNoArgs()
		project("MyProject")
		group("MyGroup")
		solution()
		test.issame(sln, api.scope.solution)
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

	function suite.solution_onStar()
		project("MyProject")
		group("MyGroup")
		filter("Debug")
		solution "*"
		test.isnil(api.scope.solution)
		test.isnil(api.scope.project)
		test.isnil(api.scope.group)
	end

	function suite.project_onStar()
		project("MyProject")
		group("MyGroup")
		filter("Debug")
		project "*"
		test.issame(sln, api.scope.solution)
		test.isnil(api.scope.project)
	end
