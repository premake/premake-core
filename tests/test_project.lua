--
-- tests/test_project.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.project = { }

	local result
	function T.project.setup()
		_ACTION = "gmake"
		result = "\n"
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
		result = result .. string.rep("-", nestlevel) .. item .. "\n"
	end
	
	function T.project.walksources_OnNoFiles()
		premake.walksources({}, {}, walktest)
		test.isequal("\n"
			.. ""
		,result)		
	end
	
	function T.project.walksources_OnSingleFile()
		local files = {
			"hello.cpp"
		}
		premake.walksources({}, files, walktest)
		test.isequal("\n"
			.. "hello.cpp\n"
		,result)
	end
	
	function T.project.walksources_OnNestedGroups()
		local files = {
			"rootfile.c",
			"level1/level1.c",
			"level1/level2/level2.c"
		}
		premake.walksources({}, files, walktest)
		test.isequal("\n"
			.. "<level1>\n"
			.. "-<level1/level2>\n"
			.. "--level1/level2/level2.c\n"
			.. "-</level1/level2>\n"
			.. "-level1/level1.c\n"
			.. "</level1>\n"
			.. "rootfile.c\n"
		,result)
	end
	
	function T.project.walksources_OnDottedFolders()
		local files = {
			"src/lua-5.1.2/lapi.c"
		}
		premake.walksources({}, files, walktest)
		test.isequal("\n"
			.. "<src>\n"
			.. "-<src/lua-5.1.2>\n"
			.. "--src/lua-5.1.2/lapi.c\n"
			.. "-</src/lua-5.1.2>\n"
			.. "</src>\n"
		,result)
	end
	
	function T.project.walksources_OnDotDotLeaders()
		local files = {
			"../src/hello.c",
		}
		premake.walksources({}, files, walktest)
		test.isequal("\n"
			.. "<../src>\n"
			.. "-../src/hello.c\n"
			.. "</../src>\n"
		,result)
	end
	