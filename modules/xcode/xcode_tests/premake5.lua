--


	dofile("../tests/testfx.lua")
	
	local xcode = dofile("../xcode/xcode.lua")
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
	
	dofile("test_xcode4_workspace.lua")
	dofile("test_xcode4_project.lua")
	dofile("test_xcode_project.lua")
	dofile("test_xcode_dependencies.lua")
	dofile("test_xcode_common.lua")
	

--
-- Register a test action
--

	newoption {
		trigger     = "test",
		description = "A suite or test to run"
	}

	newaction {
		trigger     = "test",
		description = "Run the automated test suite",

		execute = function ()
			if _OPTIONS["test"] then
				local t = string.explode(_OPTIONS["test"] or "", ".", true)
				passed, failed = test.runall(t[1], t[2])
			else
				passed, failed = test.runall()
			end

			msg = string.format("!!! %d tests passed, %d failed", passed, failed)
			if (failed > 0) then
				-- should probably return an error code here somehow
				print(msg)
				os.exit(2)
			else
				print(msg)
			end
		end
	} 