--
-- d/d.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	premake.extensions.d = {}

	local d = premake.extensions.d
	local project = premake.project
	local api = premake.api

	d.support_url = "https://bitbucket.org/premakeext/d/wiki/Home"

	d.printf = function( msg, ... )
		printf( "[premake-d] " .. msg, ...)
	end

	d.printf( "Premake D Extension (" .. d.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "tools/?.lua;" .. this_dir .. "actions/?.lua;".. package.path
--	d.printf( "Added D tools/actions directories to LUA_PATH: %s", package.path )


--
-- Register the D extension
--

	premake.D = "D"

	api.addAllowed("language", premake.D)
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
-- Patch the project structure to allow the determination of project type
-- This is then used in the override of gmake.onProject() in the
-- extension files
--

	function project.isd(prj)
		return prj.language == premake.D
	end

--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d", ".di" })
	end

--
-- Add our valid actions/tools to the predefined action(s)
-- For each of the nominated allowed toolsets in the 'dc' options above,
-- we require a similarly named tools file in 'd/tools/<dc>.lua
--

	for k,v in pairs({"dmd", "gdc", "ldc"}) do
		require( v )
		d.printf( "Loaded D tool '%s.lua'", v )
	end

--
-- For each registered premake <action>, we can simply add a file to the
-- 'd/actions/' extension subdirectory named 'd/actions/<action>.lua' and the following
-- iteration will 'require' it into the system.  Hence we can patch any/all
-- pre-defined actions by adding a named file.  This eases development as
-- we don't need to cram make stuff in with VS stuff etc.
--
	for k,v in pairs({ "gmake", "vstudio" }) do
		require( v )
		d.printf( "Loaded D action '%s.lua'", v )
	end

	-- this one depends on the monodevelop extension
	if premake.extensions.monodevelop then
		require( "monodev" )
		d.printf( "Loaded D action 'monodev.lua'", v )
	end

