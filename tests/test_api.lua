--
-- tests/test_api.lua
-- Automated test suite for the project API support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	T.api = { }

	local sln
	function T.api.setup()
		sln = solution "MySolution"
	end


--
-- premake.getobject() tests
--

	function T.api.getobject_RaisesError_OnNoContainer()
		premake.CurrentContainer = nil
		c, err = premake.getobject("container")
		test.istrue(c == nil)
		test.isequal("no active solution or project", err)
	end
	
	function T.api.getobject_RaisesError_OnNoActiveSolution()
		premake.CurrentContainer = { }
		c, err = premake.getobject("solution")
		test.istrue(c == nil)
		test.isequal("no active solution", err)
	end
	
	function T.api.getobject_RaisesError_OnNoActiveConfig()
		premake.CurrentConfiguration = nil
		c, err = premake.getobject("config")
		test.istrue(c == nil)
		test.isequal("no active solution, project, or configuration", err)
	end
		
	
--
-- premake.setarray() tests
--

	function T.api.setarray_Inserts_OnStringValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
	end

	function T.api.setarray_Inserts_OnTableValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", { "hello", "goodbye" })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.api.setarray_Appends_OnNewValues()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { "hello" }
		premake.setarray("config", "myfield", "goodbye")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.api.setarray_FlattensTables()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", { {"hello"}, {"goodbye"} })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end
	
	function T.api.setarray_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		ok, err = pcall(function () premake.setarray("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.api.setarray_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield[1])
	end
	
	

--
-- premake.setstring() tests
--

	function T.api.setstring_Sets_OnNewProperty()
		premake.CurrentConfiguration = { }
		premake.setstring("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield)
	end

	function T.api.setstring_Overwrites_OnExistingProperty()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = "hello"
		premake.setstring("config", "myfield", "goodbye")
		test.isequal("goodbye", premake.CurrentConfiguration.myfield)
	end
	
	function T.api.setstring_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		ok, err = pcall(function () premake.setstring("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.api.setstring_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.setstring("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield)
	end


--
-- solution() tests
--

	function T.api.solution_SetsCurrentObject()
		sln = solution "MySolution"
		test.istrue(sln == premake.CurrentContainer)
	end
	
	function T.api.solution_SetsName()
		sln = solution "MySolution"
		test.isequal("MySolution", sln.name)
	end
	
	function T.api.solution_SetsLocation()
		sln = solution "MySolution"
		test.isequal(os.getcwd(), sln.location)
	end

	function T.api.solution_ReturnsNil_OnNoActiveSolution()
		premake.CurrentContainer = nil
		test.isfalse(solution())
	end
	
	function T.api.solutions_ReturnsSolution_OnActiveProject()
		sln = solution "MySolution"
		project("MyProject")
		test.istrue(sln == solution())
	end

	function T.api.solution_OnNewName()
		sln = solution "MySolution"
		local sln2 = solution "MySolution2"
		test.isfalse(sln == sln2)
	end

	function T.api.solution_OnExistingName()
		sln = solution "MySolution"
		local sln2 = solution "MySolution2"
		test.istrue(sln == solution("MySolution"))
	end



--
-- configuration() tests
--
		
	function T.api.configuration_RaisesError_OnNoContainer()
		premake.CurrentContainer = nil
		local fn = function() configuration{"Debug"} end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function T.api.configuration_SetsCurrentConfiguration()
		sln = solution("MySolution")
		cfg = configuration{"Debug"}
		test.istrue(premake.CurrentConfiguration == cfg)
	end

	function T.api.configuration_AddsToContainer()
		sln = solution("MySolution")
		cfg = configuration{"Debug"}
		test.istrue(cfg == sln.blocks[#sln.blocks])
	end



--
-- project() tests
--
		
	function T.api.project_RaisesError_OnNoSolution()
		premake.CurrentContainer = nil
		local fn = function() project("MyProject") end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function T.api.project_SetsCurrentContainer()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.istrue(prj == premake.CurrentContainer)
	end

	function T.api.project_AddsToSolution()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.istrue(prj == sln.projects[1])
	end
	
	function T.api.project_SetsName()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.isequal("MyProject", prj.name)
	end
	
	function T.api.project_SetsLocation()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.isequal(os.getcwd(), prj.location)
	end
	
	function T.api.project_SetsSolution()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.istrue(sln == prj.solution)
	end

	function T.api.project_SetsConfiguration()
		sln = solution "MySolution"
		prj = project("MyProject")
		test.istrue(premake.CurrentConfiguration == prj.blocks[1])
	end

	function T.api.project_ReturnsNil_OnNoActiveProject()
		sln = solution "MySolution"
		test.isfalse(project())
	end

	function T.api.project_OnNewName()
		sln = solution "MySolution"
		local prj  = project "MyProject"
		local prj2 = project "MyProject2"
		test.isfalse(prj == prj2)
	end

	function T.api.project_OnExistingName()
		sln = solution "MySolution"
		local prj  = project "MyProject"
		local prj2 = project "MyProject2"
		test.istrue(prj == project("MyProject"))
	end

	function T.api.project_SetsUUID()
		sln = solution "MySolution"
		local prj = project "MyProject"
		test.istrue(prj.uuid)
	end
	


--
-- uuid() tests
--

	function T.api.uuid_makes_uppercase()
		premake.CurrentContainer = {}
		uuid "7CBB5FC2-7449-497f-947F-129C5129B1FB"
		test.isequal(premake.CurrentContainer.uuid, "7CBB5FC2-7449-497F-947F-129C5129B1FB")
	end
