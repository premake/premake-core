--
-- d/d.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake

	p.modules.d = {}

	local d = p.modules.d
	local api = p.api


--
-- Patch the project table to provide knowledge of D projects
--
	function p.project.isd(prj)
		return prj.language == premake.D
	end

--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d", ".di" })
	end


--
-- Register the D extension
--

	p.D = "D"

	api.addAllowed("language", p.D)
	api.addAllowed("floatingpoint", "None")
	api.addAllowed("flags", {
		"CodeCoverage",
		"Deprecated",
		"Documentation",
		"GenerateHeader",
		"GenerateJSON",
		"GenerateMap",
		"NoBoundsCheck",
--		"PIC",		// Note: this should be supported elsewhere...
		"Profile",
		"Quiet",
--		"Release",	// Note: We infer this flag from config.isDebugBuild()
		"RetainPaths",
		"SeparateCompilation",
		"SymbolsLikeC",
		"UnitTest",
		"Verbose",
	})


--
-- Register some D specific properties
--

	api.register {
		name = "versionconstants",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "versionlevel",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "debugconstants",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "debuglevel",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "docdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "docname",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "headerdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "headername",
		scope = "config",
		kind = "string",
		tokens = true,
	}


--
-- Provide information for the help output
--
	newoption
	{
		trigger		= "dc",
		value		= "VALUE",
		description	= "Choose a D compiler",
		allowed = {
			{ "dmd", "Digital Mars (dmd)" },
			{ "gdc", "GNU GDC (gdc)" },
			{ "ldc", "LLVM LDC (ldc2)" },
		}
	}


--
-- Patch actions
--
	include( "tools/dmd.lua" )
	include( "tools/gdc.lua" )
	include( "tools/ldc.lua" )

	include( "actions/gmake.lua" )
	include( "actions/vstudio.lua" )
	-- this one depends on the monodevelop extension
	if p.modules.monodevelop then
		include( "actions/monodev.lua" )
	end

	return d
