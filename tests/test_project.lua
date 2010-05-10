--
-- tests/test_project.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2008-2010 Jason Perkins and the Premake project
--

	local _project = premake.project
	
	T.project = { }

	local cfg, result
	function T.project.setup()
		_ACTION = "gmake"
		cfg = {}
		cfg.project = {}
		cfg.language = "C++"
		cfg.files = {}
		cfg.trimpaths = {}
		cfg.platform = "Native"
		result = "\n"
	end



--
-- findproject() tests
--

	function T.project.findproject_IsCaseSensitive()
		local sln = test.createsolution()
		local prj = test.createproject(sln)
		premake.buildconfigs()
		test.isnil(premake.findproject("myproject"))
	end
	
	
--
-- getfilename() tests
--

	function T.project.getfilename_ReturnsRelativePath()
		local prj = { name = "project", location = "location" }
		local r = _project.getfilename(prj, path.join(os.getcwd(), "../filename"))
		test.isequal("../filename", r)
	end
	
	function T.project.getfilename_PerformsSubstitutions()
		local prj = { name = "project", location = "location" }
		local r = _project.getfilename(prj, "%%.prj")
		test.isequal("location/project.prj", r)
	end



--
-- premake.getlinks() tests
--

	function T.project.getlinks_OnMscSystemLibs()
		_OPTIONS.cc = "msc"
		cfg.links = { "user32", "gdi32" }
		result = premake.getlinks(cfg, "all", "fullpath")
		test.isequal("user32.lib gdi32.lib", table.concat(result, " "))
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
		premake.walksources(cfg, walktest)
		test.isequal("\n"
			.. ""
		,result)		
	end
	
	
	function T.project.walksources_OnSingleFile()
		cfg.files = {
			"hello.cpp"
		}
		premake.walksources(cfg, walktest)
		test.isequal("\n"
			.. "hello.cpp\n"
		,result)
	end
	
	
	function T.project.walksources_OnNestedGroups()
		cfg.files = {
			"rootfile.c",
			"level1/level1.c",
			"level1/level2/level2.c"
		}
		premake.walksources(cfg, walktest)
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
		cfg.files = {
			"src/lua-5.1.2/lapi.c"
		}
		premake.walksources(cfg, walktest)
		test.isequal("\n"
			.. "<src>\n"
			.. "-<src/lua-5.1.2>\n"
			.. "--src/lua-5.1.2/lapi.c\n"
			.. "-</src/lua-5.1.2>\n"
			.. "</src>\n"
		,result)
	end
	
	
	function T.project.walksources_OnDotDotLeaders()
		cfg.files = {
			"../src/hello.c",
		}
		premake.walksources(cfg, walktest)
		test.isequal("\n"
			.. "<../src>\n"
			.. "-../src/hello.c\n"
			.. "</../src>\n"
		,result)
	end
