--
-- tests/tests_stress.lua
-- Stress test for Premake.
-- Copyright (c) 2009, 2013 Jason Perkins and the Premake project
--

local numprojects  = 10
local numfiles     = 100
local numbuildcfgs = 4
local numplatforms = 6


dofile("pepperfish_profiler.lua")
profiler = newProfiler()
profiler:start()


workspace "MyWorkspace"
	location "build"

	for i = 1, numbuildcfgs do
		configurations ( "BuildCfg" .. i )
	end

	for i = 1, numplatforms do
		platforms ( "Platform" .. i )
	end


for pi = 1, numprojects do

	project ("Project" .. pi)
	location "build"
	kind     "ConsoleApp"
	language "C++"

	for fi = 1, numfiles do
		files { "file" .. fi .. ".cpp" }
	end

end


newaction
{
	trigger     = "stress",
	description = "Run a stress test",
	execute     = function()
		_ACTION = "vs2008"
		premake.action.call(_ACTION)

		profiler:stop()

		local outfile = io.open("build/profile.txt", "w+" )
		profiler:report(outfile)
		outfile:close()
	end
}
