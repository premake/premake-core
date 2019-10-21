--
-- Name:        d/_preload.lua
-- Purpose:     Define the D language API's.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

-- TODO:
-- MonoDevelop/Xamarin Studio has 'workspaces', which correspond to collections
-- of Premake workspaces. If premake supports multiple workspaces, we should
-- write out a workspace file...

	local p = premake
	local api = p.api

--
-- Register the D extension
--

	p.D = "D"
	api.addAllowed("language", p.D)

	api.addAllowed("floatingpoint", "None")
	api.addAllowed("flags", {
		"CodeCoverage",
		"Color",
		"Documentation",
		"GenerateHeader",
		"GenerateJSON",
		"GenerateMap",
		"LowMem",
		"Profile",
		"Quiet",
		"RetainPaths",
		"SymbolsLikeC",
		"UnitTest",
		-- These are used by C++/D mixed $todo move them somewhere else? "flags2" "Dflags"?
		-- [Code Generation Flags]
		"UseLDC",
		"ProfileGC",
		"StackFrame",
		"StackStomp",
		"AllInstantiate",
		"BetterC",
		"Main",
		"PerformSyntaxCheckOnly",
		-- [Messages Flags]
		"ShowCommandLine",
		"Verbose",
		"ShowTLS",
		"ShowGC",
		"IgnorePragma",
		"ShowDependencies",
	})


--
-- Register some D specific properties
--

	api.register {
		name = "boundscheck",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Off",
			"On",
			"SafeOnly",
		},
	}

	api.register {
		name = "compilationmodel",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"File",
			"Package",	-- TODO: this doesn't work with gmake!!
			"Project",
		},
	}

	api.register {
		name = "checkaction",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"D",
			"C",
			"Halt",
			"Context",
		},
	}

	api.register {
		name = "computetargets",
		scope = "config",
		kind = "list:string",
	}

--	api.register {
--		name = "debugcode",
--		scope = "config",
--		kind = "string",
--	}

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
		name = "dependenciesfile",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "deprecatedfeatures",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Allow",
			"Warn",
			"Error",
		},
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

	api.register {
		name = "jsonfile",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "importdirs",
		scope = "config",
		kind = "list:path",
		tokens = true,
	}

	api.register {
		name = "preview",
		scope = "config",
		kind = "list:string",
		allowed = {
			"dip25",
			"dip1000",
			"dip1008",
			"fieldwise",
			"markdown",
			"fixAliasThis",
			"intpromote",
			"dtorfields",
		},
	}

	api.register {
		name = "revert",
		scope = "config",
		kind = "list:string",
		allowed = {
			"dip25",
			"import",
		},
	}

	api.register {
		name = "stringimportdirs",
		scope = "config",
		kind = "list:path",
		tokens = true,
	}

	api.register {
		name = "transition",
		scope = "config",
		kind = "list:string",
		allowed = {
			"field",
			"checkimports",
			"complex",
			"tls",
			"vmarkdown",
		},
	}

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

--
-- Provide information for the help output
--
	newoption
	{
		category	= "compilers",
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
-- Decide when to load the full module
--

	return function (cfg)
		return (cfg.language == p.D or cfg.language == "C" or cfg.language == "C++")
	end
