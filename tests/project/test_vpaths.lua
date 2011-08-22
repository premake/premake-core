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
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "hello.c"))
	end

	function suite.CanTrimLeadingPaths()
		vpaths { [""] = "src" }
		prepare()
		test.isequal("myproject/hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end

	function suite.PatternMayIncludeTrailingSlash()
		vpaths { [""] = "src/myproject/" }
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end

	function suite.SimpleReplacementPatterns()
		vpaths { ["sources"] = "src/myproject" }
		prepare()
		test.isequal("sources/hello.c", project.getvpath(prj, "src/myproject/hello.c"))
	end


--
-- Test wildcard patterns
--

	function suite.MatchFilePattern_ToGroup_Flat()
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end

	function suite.MatchFilePattern_ToNestedGroup_Flat()
		vpaths { ["Source/Headers"] = "**.h" }
		prepare()
		test.isequal("Source/Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	

	function suite.MatchFilePattern_ToGroup_WithTrailingSlash()
		vpaths { ["Headers/"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end

	function suite.MatchFilePattern_ToNestedGroup_Flat()
		vpaths { ["Group/Headers"] = "**.h" }
		prepare()
		test.isequal("Group/Headers/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	

	function suite.MatchFilePattern_ToGroup_Nested()
		vpaths { ["Headers/**"] = "**.h" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	

	function suite.MatchFilePattern_ToGroup_Nested_OneStar()
		vpaths { ["Headers/*"] = "**.h" }
		prepare()
		test.isequal("Headers/src/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	

	function suite.MatchFilePatternWithPath_ToGroup_Nested()
		vpaths { ["Headers/**"] = "src/**.h" }
		prepare()
		test.isequal("Headers/myproject/hello.h", project.getvpath(prj, "src/myproject/hello.h"))
	end	



--
-- Test directory dot patterns
--

	function suite.RemovesLeadingDotFolder()
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "./hello.c"))
	end

	function suite.RemovesLeadingDotDotFolder()
		prepare()
		test.isequal("hello.c", project.getvpath(prj, "../hello.c"))
	end

	function suite.RemovesMultipleLeadingDotDotFolders()
		prepare()
		test.isequal("src/hello.c", project.getvpath(prj, "../../src/hello.c"))
	end
	

--
-- Test with project locations
--

	function suite.MatchPath_OnProjectLocationSet()		
		location "build"
		files "src/hello.h"
		vpaths { [""] = "src" }
		prepare()
		test.isequal("hello.h", project.getvpath(prj, prj.files[1]))
	end

	function suite.MatchFilePattern_OnProjectLocationSet()
		location "build"
		files "src/hello.h"
		vpaths { ["Headers"] = "**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, prj.files[1]))
	end

	function suite.MatchFilePatternWithPath_OnProjectLocationSet()
		location "build"
		files "src/hello.h"
		vpaths { ["Headers"] = "src/**.h" }
		prepare()
		test.isequal("Headers/hello.h", project.getvpath(prj, prj.files[1]))
	end
