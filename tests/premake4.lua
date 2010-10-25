--
-- tests/premake4.lua
-- Automated test suite for Premake 4.x
-- Copyright (c) 2008-2010 Jason Perkins and the Premake project
--

	dofile("testfx.lua")

--
-- Some helper functions
--

	test.createsolution = function()
		local sln = solution "MySolution"
		configurations { "Debug", "Release" }
		
		local prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"

		return sln, prj
	end


	test.createproject = function(sln)
		local n = #sln.projects + 1
		if n == 1 then n = "" end
		
		local prj = project ("MyProject" .. n)
		language "C++"
		kind "ConsoleApp"
		return prj
	end


--
-- The test suites
--

	dofile("test_dofile.lua")
	dofile("test_string.lua")
	dofile("test_premake.lua")
	dofile("test_project.lua")
	dofile("test_platforms.lua")
	dofile("test_targets.lua")
	dofile("test_keywords.lua")
	dofile("test_gcc.lua")
	dofile("test_gmake_cpp.lua")
	dofile("test_gmake_cs.lua")
	dofile("base/test_api.lua")
	dofile("base/test_action.lua")
	dofile("base/test_baking.lua")
	dofile("base/test_config.lua")
	dofile("base/test_os.lua")
	dofile("base/test_path.lua")
	dofile("base/test_table.lua")
	dofile("base/test_tree.lua")
	
	-- Clean tests
	dofile("actions/test_clean.lua")
	
	-- Visual Studio tests
	dofile("test_vs2002_sln.lua")
	dofile("test_vs2003_sln.lua")
	dofile("test_vs2005_sln.lua")
	dofile("test_vs2008_sln.lua")
	dofile("test_vs2010_sln.lua")
	dofile("actions/vstudio/test_vs2005_csproj.lua")
	dofile("actions/vstudio/test_vs200x_vcproj.lua")
	dofile("actions/vstudio/test_vs200x_vcproj_linker.lua")
	dofile("actions/vstudio/test_vs2010_vcxproj.lua")
	dofile("actions/vstudio/test_vs2010_flags.lua")
	dofile("actions/vstudio/test_vs2010_links.lua")
	dofile("actions/vstudio/test_vs2010_filters.lua")
	dofile("actions/vstudio/test_vs2010_project_kinds.lua")

	-- Makefile tests
	dofile("actions/make/test_make_escaping.lua")
	dofile("actions/make/test_make_pch.lua")
	
	-- Xcode tests
	dofile("actions/xcode/test_xcode_common.lua")
	dofile("actions/xcode/test_xcode_project.lua")
	dofile("actions/xcode/test_xcode_dependencies.lua")


--
-- Register a test action
--

	newaction {
		trigger     = "test",
		description = "Run the automated test suite",
		
		execute = function ()
			passed, failed = test.runall()
			msg = string.format("%d tests passed, %d failed", passed, failed)
			if (failed > 0) then
				error(msg, 0)
			else
				print(msg)
			end
		end
	}
