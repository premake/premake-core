--
-- src/project/config.lua
-- Premake configuration object API
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	premake5.config = { }
	local project = premake5.project
	local config = premake5.config


--
-- Figures out the right form for file paths returned from
-- this configuration.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    One of "windows" or "posix".
--

	function config.getpathstyle(cfg)
		if premake.action.current().os == premake.WINDOWS then
			return premake.WINDOWS
		else
			return premake.POSIX
		end
	end


--
-- Retrieve information about a configuration's build target.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    A table with these values:
--      basename   - the target with no directory or file extension
--      name       - the target name and extension, with no directory
--      directory  - relative path to the target, with no file name
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension
--      bundlepath - the relative path and file name of the bundle
--

	function config.gettargetinfo(cfg)
		local basedir = project.getlocation(prj)

		local directory = cfg.targetdir or basedir
		directory = path.getrelative(basedir, directory)

		local basename = cfg.targetname or cfg.project.name

		local bundlename = ""
		local bundlepath = ""
		local extension = ""
		local prefix = ""
		local suffix = ""

		if cfg.kind == premake.STATICLIB then
			if cfg.system ~= premake.WINDOWS then
				prefix = "lib"
				extension = ".a"
			else
				extension = ".lib"
			end

		elseif cfg.system == premake.WINDOWS then
			if cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP then
				extension = ".exe"
			elseif cfg.kind == premake.SHAREDLIB then
				extension = ".dll"
			end

		elseif cfg.system == premake.MACOSX then
			if cfg.kind == premake.WINDOWEDAPP then
				bundlename = basename .. ".app"
				bundlepath = path.join(directory, bundlename)
				bundlepath = path.join(bundlepath, "Contents/MacOS")
			elseif cfg.kind == premake.SHAREDLIB then
				prefix = "lib"
				extension = ".dylib"
			end

		elseif cfg.system == premake.PS3 then
			if cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP then
				extension = ".elf"
			end

		else
			if cfg.kind == premake.SHAREDLIB then
				prefix = "lib"
				extension = ".so"
			end
		end

		prefix = cfg.targetprefix or prefix
		suffix = cfg.targetsuffix or suffix

		local info = {}
		info.directory  = directory
		info.basename   = basename .. suffix
		info.name       = prefix .. info.basename .. extension
		info.fullpath   = path.join(info.directory, info.name)
		info.bundlename = bundlename
		info.bundlepath = bundlepath
		info.prefix     = prefix
		info.suffix     = suffix

		if config.getpathstyle(cfg) == premake.WINDOWS then
			info.directory = path.translate(info.directory, "\\")
			info.fullpath = path.translate(info.fullpath, "\\")
		end

		return info
	end
