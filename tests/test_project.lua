--
-- tests/test_project.project.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.project = { }

	local result
	function T.project.setup()
		_ACTION = "gmake"
		result = ""
	end
	
	

--
-- premake.checkprojects() tests
--

	function T.project.checkall_Succeeds_OnValidSession()
		solution "MySolution"
		configurations "Default"
		project "MyProject"
		kind "ConsoleApp"
		language "C"
		
		ok, err = premake.checkprojects()
		test.istrue( ok )
	end
	

	function T.project.checkall_Fails_OnNoConfigurations()
		solution "MySolution"
		project "MyProject"
		
		ok, err = premake.checkprojects()
		test.isfalse( ok )
		test.isequal("solution 'MySolution' needs configurations", err)
	end
	
		
	function T.project.checkall_Fails_OnNoProjectsInSolution()
		solution "MySolution"
		configurations "Default"
		
		ok, err = premake.checkprojects()
		test.isfalse( ok )
		test.isequal("solution 'MySolution' needs at least one project", err)
	end	
	
	
	function T.project.checkall_Fails_OnNoLanguage()
		solution "MySolution"
		configurations "Default"
		project "MyProject"
		kind "ConsoleApp"
		
		ok, err = premake.checkprojects()
		test.isfalse( ok )
		test.isequal("project 'MyProject' needs a language", err)
	end
	
	
	function T.project.checkall_Fails_OnNoKind()
		solution "MySolution"
		language "C"
		configurations "Default"
		project "MyProject"
		
		ok, err = premake.checkprojects()
		test.isfalse( ok )
		test.isequal("project 'MyProject' needs a kind in configuration 'Default'", err)
	end


	function T.project.checkall_Fails_OnActionUnsupportedLanguage()
		solution "MySolution"
		configurations "Default"
		prj = project "MyProject"
		kind "ConsoleApp"
		
		prj.language = "XXX"
		
		ok, err = premake.checkprojects()
		test.isfalse(ok)
		test.isequal("the GNU Make action does not support XXX projects", err)
	end


	function T.project.checkall_Fails_OnActionUnsupportedKind()
		solution "MySolution"
		configurations "Default"
		prj = project "MyProject"
		language "C"
		
		prj.kind = "YYY"
		
		ok, err = premake.checkprojects()
		test.isfalse(ok)
		test.isequal("the GNU Make action does not support YYY projects", err)
	end
	
			

--
-- project.getobject() tests
--

	function T.project.getobject_RaisesError_OnNoContainer()
		premake.CurrentContainer = nil
		c, err = premake.getobject("container")
		test.istrue(c == nil)
		test.isequal("no active solution or project", err)
	end
	
	function T.project.getobject_RaisesError_OnNoActiveSolution()
		premake.CurrentContainer = { }
		c, err = premake.getobject("solution")
		test.istrue(c == nil)
		test.isequal("no active solution", err)
	end
	
	function T.project.getobject_RaisesError_OnNoActiveConfig()
		premake.CurrentConfiguration = nil
		c, err = premake.getobject("config")
		test.istrue(c == nil)
		test.isequal("no active solution, project, or configuration", err)
	end


--
-- premake.setstring() tests
--

	function T.project.setstring_Sets_OnNewProperty()
		premake.CurrentConfiguration = { }
		premake.setstring("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield)
	end

	function T.project.setstring_Overwrites_OnExistingProperty()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = "hello"
		premake.setstring("config", "myfield", "goodbye")
		test.isequal("goodbye", premake.CurrentConfiguration.myfield)
	end
	
	function T.project.setstring_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		ok, err = pcall(function () premake.setstring("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.project.setstring_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.setstring("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield)
	end
		
	
--
-- premake.setarray() tests
--

	function T.project.setarray_Inserts_OnStringValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
	end

	function T.project.setarray_Inserts_OnTableValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", { "hello", "goodbye" })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.project.setarray_Appends_OnNewValues()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { "hello" }
		premake.setarray("config", "myfield", "goodbye")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.project.setarray_FlattensTables()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", { {"hello"}, {"goodbye"} })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end
	
	function T.project.setarray_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		ok, err = pcall(function () premake.setarray("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.project.setarray_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.setarray("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield[1])
	end
		

--
-- premake.walksources() tests
--

	local function walktest(prj, fname, state, nestlevel)
		local item
		if (state == "GroupStart") then
			item = "<" .. fname .. ">"
		elseif (state == "GroupEnd") then
			item = "</" .. fname .. ">"
		else
			item = fname
		end
		result = result .. string.rep("-", nestlevel) .. item
	end
	
	function T.project.walksources_OnNoFiles()
		premake.walksources({}, {}, walktest)
		test.isequal(
			""
		,result)		
	end
	
	function T.project.walksources_OnSingleFile()
		local files = {
			"hello.cpp"
		}
		premake.walksources({}, files, walktest)
		test.isequal(
			"hello.cpp"
		,result)
	end
	
	function T.project.walksources_OnNestedGroups()
		local files = {
			"rootfile.c",
			"level1/level1.c",
			"level1/level2/level2.c"
		}
		premake.walksources({}, files, walktest)
		test.isequal(""
			.. "<level1>"
			.. "-<level1/level2>"
			.. "--level1/level2/level2.c"
			.. "-</level1/level2>"
			.. "-level1/level1.c"
			.. "</level1>"
			.. "rootfile.c"
		,result)
	end
	
	function T.project.walksources_OnDottedFolders()
		local files = {
			"src/lua-5.1.2/lapi.c"
		}
		premake.walksources({}, files, walktest)
		test.isequal(""
			.. "<src>"
			.. "-<src/lua-5.1.2>"
			.. "--src/lua-5.1.2/lapi.c"
			.. "-</src/lua-5.1.2>"
			.. "</src>"
		,result)
	end
	
	function T.project.walksources_OnDotDotLeaders()
		local files = {
			"../src/hello.c",
		}
		premake.walksources({}, files, walktest)
		test.isequal(""
			.. "<../src>"
			.. "-../src/hello.c"
			.. "</../src>"
		,result)
	end
	