--
-- Name:        codelite.lua
-- Purpose:     Define the CodeLite action(s).
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato (new v5 API)
--				Andrew Gough (added as extension)
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2013 Jason Perkins and the Premake project
--

	premake.extensions.codelite = {}
	local project = premake5.project

	local codelite = premake.extensions.codelite
	codelite.support_url = "https://bitbucket.org/premakeext/codelite/wiki/Home"

	codelite.printf = function( msg, ... )
		printf( "[codelite] " .. msg, ...)
	end

	codelite.printf( "Premake Codelite Extension (" .. codelite.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]; 
	package.path = this_dir .. "actions/?.lua;".. package.path

	codelite.compiler  = {}
	codelite.platforms = {}
	codelite.project   = {}
	codelite.solution  = {}

	io.indent = "  " -- 2 spaces indent, UTF8 XML file
--
-- Default compiler
--
	local function set_compiler()
		if not _OPTIONS.cc then
			_OPTIONS.cc       = "gcc"
			codelite.compiler = premake.tools.gcc
		else
			codelite.compiler = premake.tools.clang
		end
	end
--
-- Build a list of supported target platforms; I don't support cross-compiling yet
--
	local function set_platforms(sln)

		for i, platform in ipairs(sln.platforms) do

			if premake.platforms[platform] then
				if premake.platforms[platform].iscrosscompiler then
					local msg = "%s ignored: cross-compilation not supported."
					premake.warn(msg, platform)
				else
					table.insert(codelite.platforms, platform)
				end
			else
				premake.warn("%s ignored: not a valid platform.", platform)
			end
		end
	end
--
--  Supported platforms: Native, x32, x64, Universal, Universal32, Universal64
--
	newaction
	{
		trigger         = "codelite",
		shortname       = "CodeLite",
		description     = "Generate CodeLite project files",
		valid_kinds     = {"ConsoleApp", "Makefile", "SharedLib", "StaticLib", "WindowedApp"},
		valid_languages = {"C", "C++"},
		valid_tools     = {
		    cc          = {"gcc", "clang"}
		},

		onsolution = function(sln)
			set_compiler()
			set_platforms(sln)
			premake.generate(sln, sln.name .. ".workspace", codelite.solution.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, prj.name .. ".project", codelite.project.generate)
		end,

		oncleansolution = function(sln)
			premake.clean.file(sln, sln.name .. ".workspace")
			premake.clean.file(sln, sln.name .. "_wsp.mk")
			premake.clean.file(sln, sln.name .. ".tags")
			premake.clean.file(sln, ".clang")
		end,

		oncleanproject = function(prj)
			premake.clean.file(prj, prj.name .. ".project")
			premake.clean.file(prj, prj.name .. ".mk")
			premake.clean.file(prj, prj.name .. ".list")
			premake.clean.file(prj, prj.name .. ".out")
		end
	}
--
-- Return an IDE friendly name, e.g. Debug, DebugUniv32, Release64
--
	function codelite.getconfigname(cfg)

		if cfg.name then
			confName = cfg.name

			if cfg.platform then
				local confName = string.sub(cfg.name, 0, string.find(cfg.name, "|") -1)
				local platName = string.sub(cfg.name, string.find(cfg.name, "|") +1, string.len(cfg.name))

				platName = platName:gsub("ersal", "")
				platName = platName:gsub("Native", "")
				platName = platName:gsub("x", "")

				return confName .. platName
			end

			return confName
		end
	end
--
-- Return true if the platform is ok or no platforms at all in the table,
-- false otherwise.
--
-- An empty table means that the current configuration is native.
--
	function codelite.platforms.isok(platform)

		if #codelite.platforms == 0 or
			table.contains(codelite.platforms, platform) then
				return true
		end

		return false
	end

	
--
-- For each registered premake <action>, we can simply add a file to the
-- 'actions/' extension subdirectory
-- 
	for k,v in pairs({ "codelite_solution", "codelite_project" }) do
		require( v )
		codelite.printf( "Loaded action '%s.lua'", v )
	end

