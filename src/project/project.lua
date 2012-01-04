--
-- src/project/project.lua
-- Premake 5.0 project object API
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
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
-- @return
--    An iterator function returning configuration objects.
--

	function project.eachconfig(prj)
		local buildconfigs = prj.solution.configurations or {}
		local platforms = prj.solution.platforms or {}

		local i = 0
		local j = #platforms

		return function ()
			j = j + 1
			if j > #platforms then
				i = i + 1
				j = 1
			end

			if i > #buildconfigs then
				return nil
			end

			local cfg = premake5.oven.bake(prj, { buildconfigs[i], platforms[j] })
			cfg.buildcfg = buildconfigs[i]
			cfg.platform = platforms[j]

			-- For backward compatibility with the old platforms API, use the platform
			-- as the default architecture, if it would be a valid value.
			if cfg.platform then
				cfg.architecture = premake.checkvalue(cfg.platform, premake.fields.architecture.allowed)
			end

			return cfg
		end
	end
