--
-- tests/test_project.lua
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
	