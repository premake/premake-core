--
-- tests/test_platforms.lua
-- Automated test suite for platform handling functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.platforms = { }


	local testmap = { x32="Win32", x64="x64" }
	
	local sln, r
	function T.platforms.setup()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
	end


	function T.platforms.filter_OnNoSolutionPlatforms()
		premake.buildconfigs()
		r = premake.filterplatforms(sln, testmap)
		test.isequal("", table.concat(r, ":"))
	end
	
	function T.platforms.filter_OnNoSolutionPlatformsAndDefault()
		premake.buildconfigs()
		r = premake.filterplatforms(sln, testmap, "x32")
		test.isequal("x32", table.concat(r, ":"))
	end
	
	function T.platforms.filter_OnIntersection()
		platforms { "x32", "x64", "xbox360" }
		premake.buildconfigs()
		r = premake.filterplatforms(sln, testmap, "x32")
		test.isequal("x32:x64", table.concat(r, ":"))
	end
	
	function T.platforms.filter_OnNoIntersection()
		platforms { "ppc", "xbox360" }
		premake.buildconfigs()
		r = premake.filterplatforms(sln, testmap)
		test.isequal("", table.concat(r, ":"))
	end
	
	function T.platforms.filter_OnNoIntersectionAndDefault()
		platforms { "ppc", "xbox360" }
		premake.buildconfigs()
		r = premake.filterplatforms(sln, testmap, "x32")
		test.isequal("x32", table.concat(r, ":"))
	end
