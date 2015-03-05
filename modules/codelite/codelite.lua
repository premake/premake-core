--
-- Name:        codelite.lua
-- Purpose:     Define the CodeLite action(s).
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato (new v5 API)
--				Andrew Gough (added as extension)
--              Manu Evans (kept it alive and up to date)
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jason Perkins and the Premake project
--

	premake.extensions.codelite = {}

	local p = premake
	local project = p.project
	local codelite = p.extensions.codelite

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


	function codelite.cfgname(cfg)
		local cfgname = cfg.buildcfg
		if codelite.solution.multiplePlatforms then 
			cfgname = string.format("%s|%s", cfg.platform, cfg.buildcfg)
		end
		return cfgname
	end

	function codelite.esc(value)
		return value
	end

	function codelite.generateSolution(sln)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(codelite.esc)

		p.generate(sln, ".workspace", codelite.solution.generate)
	end

	function codelite.generateProject(prj)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(codelite.esc)

		if project.iscpp(prj) then
			p.generate(prj, ".project", codelite.project.generate)
		end
	end

	function codelite.cleanSolution(sln)
		p.clean.file(sln, sln.name .. ".workspace")
		p.clean.file(sln, sln.name .. "_wsp.mk")
		p.clean.file(sln, sln.name .. ".tags")
		p.clean.file(sln, ".clang")
	end

	function codelite.cleanProject(prj)
		p.clean.file(prj, prj.name .. ".project")
		p.clean.file(prj, prj.name .. ".mk")
		p.clean.file(prj, prj.name .. ".list")
		p.clean.file(prj, prj.name .. ".out")
	end

	function codelite.cleanTarget(prj)
		-- TODO..
	end


--
--  Supported platforms: Native, x32, x64, Universal, Universal32, Universal64
--
	newaction
	{
		-- Metadata for the command line and help system

		trigger         = "codelite",
		shortname       = "CodeLite",
		description     = "Generate CodeLite project files",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "Makefile", "SharedLib", "StaticLib" },
		valid_languages = { "C", "C++" },
		valid_tools     = {
		    cc = { "gcc", "clang", "msc" }
		},

		-- Solution and project generation logic

		onSolution = codelite.generateSolution,
		onProject  = codelite.generateProject,

		onCleanSolution = codelite.cleanSolution,
		onCleanProject  = codelite.cleanProject,
		onCleanTarget   = codelite.cleanTarget
	}


--
-- For each registered premake <action>, we can simply add a file to the
-- 'actions/' extension subdirectory
-- 
	for k,v in pairs({ "codelite_solution", "codelite_project" }) do
		require( v )
		codelite.printf( "Loaded action '%s.lua'", v )
	end

