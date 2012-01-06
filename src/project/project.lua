--
-- src/project/project.lua
-- Premake project object API
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

			return project.getconfig(prj, buildconfigs[i], platforms[j])
		end
	end


--
-- Retrieve the project's configuration information for a particular build 
-- configuration/platform pair.
--
-- @param prj
--    The project object to query.
-- @param buildcfg
--    The name of the build configuration on which to filter.
-- @param platform
--    Optional; the name of the platform on which to filter.
-- @return
--    A configuration object.
--

	function project.getconfig(prj, buildcfg, platform)
		local cfg = premake5.oven.bake(prj, { buildcfg, platform })
		cfg.buildcfg = buildcfg
		cfg.platform = platform

		-- For backward compatibility with the old platforms API, use platform
		-- as the default architecture, if it would be a valid value.
		if cfg.platform then
			cfg.architecture = premake.checkvalue(cfg.platform, premake.fields.architecture.allowed)
		end

		-- If no system is specified, try to find one
		cfg.system = cfg.system or premake.action.current().os or os.get()

		return cfg
	end


--
-- Retrieve the project's file system location.
--
-- @param prj
--    The project object to query.
-- @param relativeto
--    Optional; if supplied, the project location will be made relative
--    to this path.
-- @return
--    The path to the project's file system location.
--

	function project.getlocation(prj, relativeto)
		local location = prj.location or prj.solution.location or prj.basedir
		if relativeto then
			location = path.getrelative(relativeto, location)
		end
		return location
	end
