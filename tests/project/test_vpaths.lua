--
-- tests/project/test_vpaths.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.project_vpaths = { }
	local suite = T.project_vpaths	
	local project = premake.project


--
-- Setup and teardown
--

	local sln, prj
	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		premake.bake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
	end
	
--
-- Test simple replacements
--

	function suite.ReturnsOriginalPath_OnNoVpaths()
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "hello.c"))
	end

	function suite.ReturnsOriginalPath_OnNoMatches()
		vpaths { ["**.h"] = "Headers" }
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "hello.c"))
	end


	function suite.CanTrimLeadingPaths()
		vpaths { ["src"] = "" }
		prepare()
		test.isequal("myproject/hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end


	function suite.PatternMayIncludeTrailingSlash()
		vpaths { ["src/myproject/"] = "" }
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end


	function suite.SimpleReplacementPatterns()
		vpaths { ["src/myproject"] = "sources" }
		prepare()
		test.isequal("sources/hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end

--
-- Test wildcard patterns
--

	function suite.MatchFilePattern_ToGroup_Flat()
		vpaths { ["**.h"] = "Headers" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end


	function suite.MatchFilePattern_ToNestedGroup_Flat()
		vpaths { ["**.h"] = "Source/Headers" }
		prepare()
		test.isequal("Source/Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	


	function suite.MatchFilePattern_ToGroup_WithTrailingSlash()
		vpaths { ["**.h"] = "Headers/" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end


	function suite.MatchFilePattern_ToNestedGroup_Flat()
		vpaths { ["**.h"] = "Group/Headers" }
		prepare()
		test.isequal("Group/Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	


	function suite.MatchFilePattern_ToGroup_Nested()
		vpaths { ["**.h"] = "Headers/**" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	


	function suite.MatchFilePattern_ToGroup_Nested_OneStar()
		vpaths { ["**.h"] = "Headers/*" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	


	function suite.MatchFilePatternWithPath_ToGroup_Nested()
		vpaths { ["src/**.h"] = "Headers/**" }
		prepare()
		test.isequal("Headers/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	
