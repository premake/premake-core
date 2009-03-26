--
-- tests/premake4.lua
-- Automated test suite for Premake 4.x
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	dofile("testfx.lua")
	dofile("test_dofile.lua")
	dofile("test_os.lua")
	dofile("test_path.lua")
	dofile("test_string.lua")
	dofile("test_table.lua")
	dofile("test_template.lua")
	dofile("test_premake.lua")
	dofile("test_project.lua")
	dofile("test_api.lua")
	dofile("test_targets.lua")
	dofile("test_keywords.lua")
	dofile("test_vstudio.lua")
	dofile("test_vs2002_sln.lua")
	dofile("test_vs2003_sln.lua")
	dofile("test_vs2005_sln.lua")
	dofile("test_vs2008_sln.lua")
	dofile("test_vs200x_vcproj.lua")



--
-- Register a test action
--

	premake.actions["test"] = {
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
