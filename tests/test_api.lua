--
-- tests/test_api.lua
-- Automated test suite for the project API support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	T.api = { }


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


