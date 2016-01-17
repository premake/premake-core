---
-- tests/tests_stress.lua
--
-- Stress test for Premake. Creates a large (tunable, see local variables
-- at start of file) number of projects, files, and configurations. Then
-- generates them all while profiling the result.
--
-- Run it like normal, i.e. `premake5 --file=test_stress.lua gmake`. The 
-- profile results will be placed at `build/profile.txt`.
--
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
---

--
-- Test parameters
--

	local numProjects  = 15
	local numFiles     = 100
	local numBuildCfgs = 6
	local numPlatforms = 6

	local prjKind      = "ConsoleApp"
	local prjLanguage  = "C++"


--
-- Generate the workspace and projects
--

	workspace "MyWorkspace"
		location "build"

	for i = 1, numBuildCfgs do
		configurations ( "BuildCfg" .. i )
	end

	for i = 1, numPlatforms do
		platforms ( "Platform" .. i )
	end

	for i = 1, numProjects do
		project ("Project" .. i)
			location "build"
			kind     ( prjKind )
			language ( prjLanguage )

		for j = 1, numFiles do
			files { "file" .. j .. ".cpp" }
		end
	end


--
-- Install profiling extensions
-- TODO: would be nice to build these into the core exe, and could be
--       triggered with a flag, i.e. `premake5 --profile gmake`
--

	dofile("pepperfish_profiler.lua")
	profiler = newProfiler()
	profiler:start()

	premake.override(premake.main, "postAction", function(base)
		base()

		profiler:stop()

		local outfile = io.open("build/profile.txt", "w+" )
		profiler:report(outfile)
		outfile:close()		
	end)
