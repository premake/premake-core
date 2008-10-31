--
-- tests/test_functions.lua
-- Automated test suite for the project API.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.functions = { }

	local sln
	function T.functions.setup()
		sln = solution "MySolution"
	end
	
	
--
-- solution() tests
--

	function T.functions.solution_SetsCurrentObject()
		test.istrue(sln == premake.CurrentContainer)
	end
	
	function T.functions.solution_SetsName()
		test.isequal("MySolution", sln.name)
	end
	
	function T.functions.solution_SetsLocation()
		test.isequal(os.getcwd(), sln.location)
	end

	function T.functions.solution_ReturnsNil_OnNoActiveSolution()
		premake.CurrentContainer = nil
		test.isfalse(solution())
	end
	
	function T.functions.solutions_ReturnsSolution_OnActiveProject()
		project("MyProject")
		test.istrue(sln == solution())
	end

	function T.functions.solution_OnNewName()
		local sln2 = solution "MySolution2"
		test.isfalse(sln == sln2)
	end

	function T.functions.solution_OnExistingName()
		local sln2 = solution "MySolution2"
		test.istrue(sln == solution("MySolution"))
	end



--
-- configuration() tests
--
		
	function T.functions.configuration_RaisesError_OnNoContainer()
		premake.CurrentContainer = nil
		local fn = function() configuration{"Debug"} end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function T.functions.configuration_SetsCurrentConfiguration()
		sln = solution("MySolution")
		cfg = configuration{"Debug"}
		test.istrue(premake.CurrentConfiguration == cfg)
	end

	function T.functions.configuration_AddsToContainer()
		sln = solution("MySolution")
		cfg = configuration{"Debug"}
		test.istrue(cfg == sln.blocks[#sln.blocks])
	end


--
-- project() tests
--
		
	function T.functions.project_RaisesError_OnNoSolution()
		premake.CurrentContainer = nil
		local fn = function() project("MyProject") end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function T.functions.project_SetsCurrentContainer()
		prj = project("MyProject")
		test.istrue(prj == premake.CurrentContainer)
	end

	function T.functions.project_AddsToSolution()
		prj = project("MyProject")
		test.istrue(prj == sln.projects[1])
	end
	
	function T.functions.project_SetsName()
		prj = project("MyProject")
		test.isequal("MyProject", prj.name)
	end
	
	function T.functions.project_SetsLocation()
		prj = project("MyProject")
		test.isequal(os.getcwd(), prj.location)
	end
	
	function T.functions.project_SetsSolution()
		prj = project("MyProject")
		test.istrue(sln == prj.solution)
	end

	function T.functions.project_SetsConfiguration()
		prj = project("MyProject")
		test.istrue(premake.CurrentConfiguration == prj.blocks[1])
	end

	function T.functions.project_ReturnsNil_OnNoActiveProject()
		test.isfalse(project())
	end

	function T.functions.project_OnNewName()
		local prj  = project "MyProject"
		local prj2 = project "MyProject2"
		test.isfalse(prj == prj2)
	end

	function T.functions.project_OnExistingName()
		local prj  = project "MyProject"
		local prj2 = project "MyProject2"
		test.istrue(prj == project("MyProject"))
	end

