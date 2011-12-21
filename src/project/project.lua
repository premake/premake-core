--
-- src/project/project.lua
-- Premake 5.0 project object API
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	premake5.project = { }
	local project = premake5.project

--
-- Returns an iterator function for the configuration objects contained by
-- the project. Each configuration corresponds to a build configuration/
-- platform pair (i.e. "Debug|x32") as specified in the solution.
--
-- @param prj
--    The project object to query.
-- @returns
--    An iterator function returning configuration objects.
--

	function project.eachconfig(prj)
		return function ()
		end
	end
