--
-- tests/project/test_vpaths.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_vpaths = { }
	local suite = T.project_vpaths	
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj, cfg
	local cwd
	
	function suite.setup()
		sln = test.createsolution()
		cwd = os.getcwd() .. '/'
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
	end

	
--
-- Test simple replacements
--

	function suite.ReturnsOriginalPath_OnNoVpaths()
		files { "hello.c" }
		prepare()
		test.isequal(cfg.files[1], project.getvpath(prj, cfg.files[1]))
	end

	function suite.ReturnsOriginalPath_OnNoMatches()
		files { "hello.c" }
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal(cfg.files[1], project.getvpath(prj, cfg.files[1]))
	end

	function suite.CanTrimLeadingPaths()
		files { "src/myproject/hello.c" }
		vpaths { [""] = "src" }
		prepare()
		test.isequal("myproject/hello.c", project.getvpath(prj, cfg.files[1]))
	end

	function suite.PatternMayIncludeTrailingSlash()
		files { "src/myproject/hello.c" }
		vpaths { [""] = "src/myproject/" }
		prepare()
		test.isequal("hello.c", project.getvpath(prj, cfg.files[1]))
	end

	function suite.SimpleReplacementPatterns()
		files { "src/myproject/hello.c" }
		vpaths { ["sources"] = "src/myproject" }
		prepare()
		test.isequal("sources/hello.c", project.getvpath(prj, cfg.files[1]))
	end


--
-- Test wildcard patterns
--

	function suite.MatchFilePattern_ToGroup_Flat()
		files { "src/myproject/hello.h" }
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end

	function suite.MatchFilePattern_ToNestedGroup_Flat()
		files { "src/myproject/hello.h" }
		vpaths { ["Source/Headers"] = "**.h" }
		prepare()
		test.isequal("Source/Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end	

	function suite.MatchFilePattern_ToGroup_WithTrailingSlash()
		files { "src/myproject/hello.h" }
		vpaths { ["Headers/"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end

	function suite.MatchFilePattern_ToNestedGroup_Flat()
		files { "src/myproject/hello.h" }
		vpaths { ["Group/Headers"] = "**.h" }
		prepare()
		test.isequal("Group/Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end	

	function suite.MatchFilePattern_ToGroup_Nested()
		files { "src/myproject/hello.h" }
		vpaths { ["Headers/**"] = "**.h" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, cfg.files[1]))
	end	

	function suite.MatchFilePattern_ToGroup_Nested_OneStar()
		files { "src/myproject/hello.h" }
		vpaths { ["Headers/*"] = "**.h" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, cfg.files[1]))
	end	

	function suite.MatchFilePatternWithPath_ToGroup_Nested()
		files { "src/myproject/hello.h" }
		vpaths { ["Headers/**"] = "src/**.h" }
		prepare()
		test.isequal("Headers/myproject/hello.h", project.getvpath(prj, cfg.files[1]))
	end	


--
-- Test with project locations
--

	function suite.MatchPath_OnProjectLocationSet()		
		location "build"
		files "src/hello.h"
		vpaths { [""] = "src" }
		prepare()
		test.isequal("hello.h", project.getvpath(prj, cfg.files[1]))
	end

	function suite.MatchFilePattern_OnProjectLocationSet()
		location "build"
		files "src/hello.h"
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end

	function suite.MatchFilePatternWithPath_OnProjectLocationSet()
		location "build"
		files "src/hello.h"
		vpaths { ["Headers"] = "src/**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, cfg.files[1]))
	end
