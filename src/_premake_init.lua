--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local api = p.api

	local DOC_URL = "See https://github.com/premake/premake-core/wiki/"


-----------------------------------------------------------------------------
--
-- Register the core API functions.
--
-----------------------------------------------------------------------------

	api.register {
		name = "architecture",
		scope = "config",
		kind = "string",
		allowed = {
			"universal",
			p.X86,
			p.X86_64,
			p.ARM,
			p.ARM64,
		},
		aliases = {
			i386  = p.X86,
			amd64 = p.X86_64,
			x32   = p.X86,	-- these should be DEPRECATED
			x64   = p.X86_64,
		},
	}

	api.register {
		name = "atl",
		scope = "config",
		kind  = "string",
		allowed = {
			"Off",
			"Dynamic",
			"Static",
		},
	}

	api.register {
		name = "basedir",
		scope = "project",
		kind = "path"
	}

	api.register {
		name = "buildaction",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "buildcommands",
		scope = { "config", "rule" },
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "buildcustomizations",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "builddependencies",
		scope = { "rule" },
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "buildlog",
		scope = { "config" },
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "buildmessage",
		scope = { "config", "rule" },
		kind = "string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "buildoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "buildoutputs",
		scope = { "config", "rule" },
		kind = "list:path",
		tokens = true,
		pathVars = false,
	}

	api.register {
		name = "buildinputs",
		scope = "config",
		kind = "list:file",
		tokens = true,
		pathVars = false,
	}

	api.register {
		name = "buildrule",     -- DEPRECATED
		scope = "config",
		kind = "table",
		tokens = true,
	}

	api.register {
		name = "characterset",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"ASCII",
			"MBCS",
			"Unicode",
		}
	}

	api.register {
		name = "cleancommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "cleanextensions",
		scope = "config",
		kind = "list:string",
	}

	api.register {
		name = "clr",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"On",
			"Pure",
			"Safe",
			"Unsafe",
			"NetCore",
		}
	}

	api.register {
		name = "compilebuildoutputs",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "compileas",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"C",
			"C++",
			"Objective-C",
			"Objective-C++",
			"Module",
			"ModulePartition",
			"HeaderUnit"
		}
	}

	api.register {
		name = "allmodulespublic",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "configmap",
		scope = "project",
		kind = "list:keyed:array:string",
	}

	api.register {
		name = "configurations",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "consumewinrtextension",
		scope = "config",
		kind = "boolean",
	}

	api.register {
		name = "copylocal",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
	}

	api.register {
		name = "debugargs",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
		allowDuplicates = true,
	}

	api.register {
		name = "debugcommand",
		scope = "config",
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "debugdir",
		scope = "config",
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "debugenvs",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "debugformat",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"c7",
			"Dwarf",
			"SplitDwarf",
		},
	}

	api.register {
		name = "debugger",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"GDB",
			"LLDB",
		}
	}

	api.register {
		name = "debuggertype",
		scope = "config",
		kind = "string",
		allowed = {
			"Mixed",
			"NativeOnly",
			"ManagedOnly",
			"NativeWithManagedCore"
		}
	}

	api.register {
		name = "debugpathmap",
		scope = "config",
		kind = "list:keyed:path",
		tokens = true,
	}

	api.register {
		name = "debugtoolargs",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "debugtoolcommand",
		scope = "config",
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "defaultplatform",
		scope = "project",
		kind = "string",
	}

	api.register {
		name = "defines",
		scope = "config",
		kind = "list:string",
		tokens = true,
		allowed = function(value)
			return iif(value == "", nil, value)
		end
	}

	api.register {
		name = "dependson",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "disablewarnings",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "display",
		scope = "rule",
		kind = "string",
	}

	api.register {
		name = "dpiawareness",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"None",
			"High",
			"HighPerMonitor",
		}
	}

	api.register {
		name = "editandcontinue",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
		},
	}

	api.register {
		name = "exceptionhandling",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
			"SEH",
			"CThrow",
		},
	}

	api.register {
		name = "enablewarnings",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "entrypoint",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "fastuptodate",
		scope = "project",
		kind = "boolean",
	}

	api.register {
		name = "fatalwarnings",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "fileextension",
		scope = "rule",
		kind = "list:string",
	}

	api.register {
		name = "filename",
		scope = { "project", "rule" },
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "files",
		scope = "config",
		kind = "list:file",
		tokens = true,
	}

	api.register {
		name = "functionlevellinking",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "flags",
		scope = "config",
		kind  = "list:string",
		allowed = {
			"Component",           -- DEPRECATED
			"DebugEnvsDontMerge",
			"DebugEnvsInherit",
			"EnableSSE",           -- DEPRECATED
			"EnableSSE2",          -- DEPRECATED
			"ExcludeFromBuild",
			"ExtraWarnings",       -- DEPRECATED
			"FatalCompileWarnings",
			"FatalLinkWarnings",
			"FloatFast",           -- DEPRECATED
			"FloatStrict",         -- DEPRECATED
			"LinkTimeOptimization",
			"Managed",             -- DEPRECATED
			"Maps",
			"MFC",
			"MultiProcessorCompile",
			"NativeWChar",         -- DEPRECATED
			"No64BitChecks",
			"NoCopyLocal",
			"NoEditAndContinue",   -- DEPRECATED
			"NoFramePointer",      -- DEPRECATED
			"NoImplicitLink",
			"NoImportLib",         -- DEPRECATED
			"NoIncrementalLink",
			"NoManifest",
			"NoMinimalRebuild",
			"NoNativeWChar",       -- DEPRECATED
			"NoPCH",
			"NoRuntimeChecks",
			"NoBufferSecurityCheck",
			"NoWarnings",          -- DEPRECATED
			"OmitDefaultLibrary",
			"Optimize",            -- DEPRECATED
			"OptimizeSize",        -- DEPRECATED
			"OptimizeSpeed",       -- DEPRECATED
			"RelativeLinks",
			"ReleaseRuntime",      -- DEPRECATED
			"ShadowedVariables",
			"StaticRuntime",       -- DEPRECATED
			"Symbols",             -- DEPRECATED
			"UndefinedIdentifiers",
			"WinMain",             -- DEPRECATED
			"WPF",
			"C++11",               -- DEPRECATED
			"C++14",               -- DEPRECATED
			"C90",                 -- DEPRECATED
			"C99",                 -- DEPRECATED
			"C11",                 -- DEPRECATED
		},
		aliases = {
			FatalWarnings = { "FatalWarnings", "FatalCompileWarnings", "FatalLinkWarnings" },
			Optimise = 'Optimize',
			OptimiseSize = 'OptimizeSize',
			OptimiseSpeed = 'OptimizeSpeed',
		},
	}

	api.register {
		name = "floatingpoint",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Fast",
			"Strict",
		}
	}

	api.register {
		name = "floatingpointexceptions",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "inlining",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Disabled",
			"Explicit",
			"Auto"
		}
	}

	api.register {
		name = "callingconvention",
		scope = "config",
		kind = "string",
		allowed = {
			"Cdecl",
			"FastCall",
			"StdCall",
			"VectorCall",
		}
	}

	api.register {
		name = "forceincludes",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
	}

	api.register {
		name = "forceusings",
		scope = "config",
		kind = "list:file",
		tokens = true,
	}

	api.register {
		name = "dotnetframework",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "enabledefaultcompileitems",
		scope = "config",
		kind = "boolean",
		default = false
	}

	api.register {
		name = "csversion",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "ignoredefaultlibraries",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
	}

	api.register {
		name = "inheritdependencies",
		scope = "config",
		kind = "boolean",
	}

	api.register {
		name = "icon",
		scope = "project",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "imageoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "imagepath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "implibdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "implibextension",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibname",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibprefix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibsuffix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "includedirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "intrinsics",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "bindirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "kind",
		scope = "config",
		kind = "string",
		allowed = {
			"ConsoleApp",
			"Makefile",
			"None",
			"SharedLib",
			"StaticLib",
			"WindowedApp",
			"Utility",
			"SharedItems",
		},
	}

	api.register {
		name = "sharedlibtype",
		scope = "project",
		kind = "string",
		allowed = {
			"OSXBundle",
			"OSXFramework",
			"XCTest",
		},
	}

	api.register {
		name = "language",
		scope = "project",
		kind = "string",
		allowed = {
			"C",
			"C++",
			"C#",
			"F#"
		}
	}

	api.register {
		name = "documentationfile",
		scope = "project",
		kind = "string",
	}

	api.register {
		name = "cdialect",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"C89",
			"C90",
			"C99",
			"C11",
			"C17",
			"gnu89",
			"gnu90",
			"gnu99",
			"gnu11",
			"gnu17"
		}
	}

	api.register {
		name = "cppdialect",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"C++latest",
			"C++98",
			"C++0x",
			"C++11",
			"C++1y",
			"C++14",
			"C++1z",
			"C++17",
			"C++2a",
			"C++20",
			"C++2b",
			"C++23",
			"gnu++98",
			"gnu++0x",
			"gnu++11",
			"gnu++1y",
			"gnu++14",
			"gnu++1z",
			"gnu++17",
			"gnu++2a",
			"gnu++20",
			"gnu++2b",
			"gnu++23",
		}
	}

	api.register {
		name = "conformancemode",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "usefullpaths",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "removeunreferencedcodedata",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "libdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "frameworkdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "linkbuildoutputs",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "linkoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "links",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
	}

	api.register {
		name = "linkgroups",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"On",
		}
	}

	api.register {
		name = "linker",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"LLD",
		}
	}

	api.register {
		name = "locale",
		scope = "config",
		kind = "string",
		tokens = false,
	}

	api.register {
		name = "location",
		scope = { "project", "rule" },
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "makesettings",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "namespace",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "nativewchar",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
		}
	}

	api.register {
		name = "nuget",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "nugetsource",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "objdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "optimize",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"On",
			"Debug",
			"Size",
			"Speed",
			"Full",
		}
	}

	api.register {
		name = "runpathdirs",
		scope = "config",
		kind = "list:path",
		tokens = true,
	}

	api.register {
		name = "runtime",
		scope = "config",
		kind = "string",
		allowed = {
			"Debug",
			"Release",
		}
	}

	api.register {
		name = "pchheader",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "pchsource",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "pic",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"On",
		}
	}

	api.register {
		name = "platforms",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "postbuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
		allowDuplicates = true,
	}

	api.register {
		name = "postbuildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "prebuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
		allowDuplicates = true,
	}

	api.register {
		name = "prebuildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "prelinkcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "prelinkmessage",
		scope = "config",
		kind = "string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "propertydefinition",
		scope = "rule",
		kind = "list:table",
	}

	api.register {
		name = "rebuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "resdefines",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "resincludedirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "resoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "resourcegenerator",
		scope = "project",
		kind = "string",
        allowed = {
            "internal",
            "public"
        }
	}

	api.register {
		name = "rtti",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
		},
	}

	api.register {
		name = "rules",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "sanitize",
		scope = "config",
		kind = "list:string",
		allowed = {
			"Address",
			"Fuzzer",              -- Visual Studio 2022+ only
		}
	}

	api.register {
		name = "startproject",
		scope = "workspace",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "staticruntime",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off"
		}
	}

	api.register {
		name = "strictaliasing",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"Level1",
			"Level2",
			"Level3",
		}
	}

	api.register {
		name = "stringpooling",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "symbols",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
			"FastLink",    -- Visual Studio 2015+ only, considered 'On' for all other cases.
			"Full",        -- Visual Studio 2017+ only, considered 'On' for all other cases.
		},
	}

	api.register {
		name = "symbolspath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "syslibdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "system",
		scope = "config",
		kind = "string",
		allowed = {
			"aix",
			"bsd",
			"haiku",
			"ios",
			"linux",
			"macosx",
			"solaris",
			"uwp",
			"wii",
			"windows",
		},
	}

	api.register {
		name = "systemversion",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "tags",
		scope = "config",
		kind = "list:string",
	}

	api.register {
		name = "tailcalls",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "targetdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "targetextension",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetname",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetprefix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetsuffix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "toolset",
		scope = "config",
		kind = "string",
		allowed = function(value)
			value = value:lower()
			local tool, version = p.tools.canonical(value)
			if tool then
				return p.tools.normalize(value)
			else
				return nil
			end
		end,
	}

	api.register {
		name = "toolsversion",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "customtoolnamespace",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "undefines",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "usingdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "uuid",
		scope = "project",
		kind = "string",
		allowed = function(value)
			local ok = true
			if (#value ~= 36) then ok = false end
			for i=1,36 do
				local ch = value:sub(i,i)
				if (not ch:find("[ABCDEFabcdef0123456789-]")) then ok = false end
			end
			if (value:sub(9,9) ~= "-")   then ok = false end
			if (value:sub(14,14) ~= "-") then ok = false end
			if (value:sub(19,19) ~= "-") then ok = false end
			if (value:sub(24,24) ~= "-") then ok = false end
			if (not ok) then
				return nil, "invalid UUID"
			end
			return value:upper()
		end
	}

	api.register {
		name = "vectorextensions",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"AVX",
			"AVX2",
			"IA32",
			"SSE",
			"SSE2",
			"SSE3",
			"SSSE3",
			"SSE4.1",
			"SSE4.2",
		}
	}

	api.register {
		name = "isaextensions",
		scope = "config",
		kind = "list:string",
		allowed = {
			"MOVBE",
			"POPCNT",
			"PCLMUL",
			"LZCNT",
			"BMI",
			"BMI2",
			"F16C",
			"AES",
			"FMA",
			"FMA4",
			"RDRND",
		}
	}

	api.register {
		name = "vpaths",
		scope = "project",
		kind = "list:keyed:list:path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "warnings",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"Default",
			"High",
			"Extra",
			"Everything",
		}
	}

	api.register {
		name = "largeaddressaware",
		scope = "config",
		kind = "boolean",
	}

	api.register {
		name = "editorintegration",
		scope = "workspace",
		kind = "boolean",
	}

	api.register {
		name = "preferredtoolarchitecture",
		scope = "workspace",
		kind = "string",
		allowed = {
			"Default",
			p.X86,
			p.X86_64,
		}
	}

	api.register {
		name = "unsignedchar",
		scope = "config",
		kind = "boolean",
	}

	p.api.register {
		name = "structmemberalign",
		scope = "config",
		kind = "integer",
		allowed = {
			"1",
			"2",
			"4",
			"8",
			"16",
		}
	}

	api.register {
		name = "omitframepointer",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off"
		}
	}

	api.register {
		name = "visibility",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Hidden",
			"Internal",
			"Protected"
		}
	}

	api.register {
		name = "inlinesvisibility",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Hidden"
		}
	}

	api.register {
		name = "assemblydebug",
		scope = "config",
		kind  = "boolean"
	}

	api.register {
		name = "justmycode",
		scope = "project",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	api.register {
		name = "openmp",
		scope = "project",
		kind = "string",
		allowed = {
			"On",
			"Off"
		}
	}

	api.register {
		name = "externalincludedirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "externalwarnings",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"Default",
			"High",
			"Extra",
			"Everything",
		}
	}

	api.register {
		name = "includedirsafter",
		scope = "config",
		kind = "list:directory",
		tokens = true
	}

	api.register {   -- DEPRECATED 2021-11-16
		name = "sysincludedirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.deprecateField("sysincludedirs", 'Use `externalincludedirs` instead.',
	function(value)
		externalincludedirs(value)
	end)

-----------------------------------------------------------------------------
--
-- Field name aliases for backward compatibility
--
-----------------------------------------------------------------------------

	api.alias("buildcommands", "buildCommands")
	api.alias("builddependencies", "buildDependencies")
	api.alias("buildmessage", "buildMessage")
	api.alias("buildoutputs", "buildOutputs")
	api.alias("cleanextensions", "cleanExtensions")
	api.alias("dotnetframework", "framework")
	api.alias("editandcontinue", "editAndContinue")
	api.alias("fileextension", "fileExtension")
	api.alias("propertydefinition", "propertyDefinition")
	api.alias("removefiles", "excludes")


-----------------------------------------------------------------------------
--
-- Handlers for deprecated fields and values.
--
-----------------------------------------------------------------------------

	-- 13 Apr 2017

	api.deprecateField("buildrule", 'Use `buildcommands`, `buildoutputs`, and `buildmessage` instead.',
	function(value)
		if value.description then
			buildmessage(value.description)
		end
		buildcommands(value.commands)
		buildoutputs(value.outputs)
	end)


	api.deprecateValue("flags", "Component", 'Use `buildaction "Component"` instead.',
	function(value)
		buildaction "Component"
	end)


	api.deprecateValue("flags", "EnableSSE", 'Use `vectorextensions "SSE"` instead.',
	function(value)
		vectorextensions("SSE")
	end,
	function(value)
		vectorextensions "Default"
	end)


	api.deprecateValue("flags", "EnableSSE2", 'Use `vectorextensions "SSE2"` instead.',
	function(value)
		vectorextensions("SSE2")
	end,
	function(value)
		vectorextensions "Default"
	end)


	api.deprecateValue("flags", "FloatFast", 'Use `floatingpoint "Fast"` instead.',
	function(value)
		floatingpoint("Fast")
	end,
	function(value)
		floatingpoint "Default"
	end)


	api.deprecateValue("flags", "FloatStrict", 'Use `floatingpoint "Strict"` instead.',
	function(value)
		floatingpoint("Strict")
	end,
	function(value)
		floatingpoint "Default"
	end)


	api.deprecateValue("flags", "NativeWChar", 'Use `nativewchar "On"` instead."',
	function(value)
		nativewchar("On")
	end,
	function(value)
		nativewchar "Default"
	end)


	api.deprecateValue("flags", "NoNativeWChar", 'Use `nativewchar "Off"` instead."',
	function(value)
		nativewchar("Off")
	end,
	function(value)
		nativewchar "Default"
	end)


	api.deprecateValue("flags", "Optimize", 'Use `optimize "On"` instead.',
	function(value)
		optimize ("On")
	end,
	function(value)
		optimize "Off"
	end)


	api.deprecateValue("flags", "OptimizeSize", 'Use `optimize "Size"` instead.',
	function(value)
		optimize ("Size")
	end,
	function(value)
		optimize "Off"
	end)


	api.deprecateValue("flags", "OptimizeSpeed", 'Use `optimize "Speed"` instead.',
	function(value)
		optimize ("Speed")
	end,
	function(value)
		optimize "Off"
	end)


	api.deprecateValue("flags", "ReleaseRuntime", 'Use `runtime "Release"` instead.',
	function(value)
		runtime "Release"
	end,
	function(value)
	end)


	api.deprecateValue("flags", "ExtraWarnings", 'Use `warnings "Extra"` instead.',
	function(value)
		warnings "Extra"
	end,
	function(value)
		warnings "Default"
	end)


	api.deprecateValue("flags", "NoWarnings", 'Use `warnings "Off"` instead.',
	function(value)
		warnings "Off"
	end,
	function(value)
		warnings "Default"
	end)

	api.deprecateValue("flags", "Managed", 'Use `clr "On"` instead.',
	function(value)
		clr "On"
	end,
	function(value)
		clr "Off"
	end)


	api.deprecateValue("flags", "NoEditAndContinue", 'Use editandcontinue "Off"` instead.',
	function(value)
		editandcontinue "Off"
	end,
	function(value)
		editandcontinue "On"
	end)


	-- 21 June 2016

	api.deprecateValue("flags", "Symbols", 'Use `symbols "On"` instead',
	function(value)
		symbols "On"
	end,
	function(value)
		symbols "Default"
	end)


	-- 31 January 2017

	api.deprecateValue("flags", "C++11", 'Use `cppdialect "C++11"` instead',
	function(value)
		cppdialect "C++11"
	end,
	function(value)
		cppdialect "Default"
	end)

	api.deprecateValue("flags", "C++14", 'Use `cppdialect "C++14"` instead',
	function(value)
		cppdialect "C++14"
	end,
	function(value)
		cppdialect "Default"
	end)

	api.deprecateValue("flags", "C90",   'Use `cdialect "gnu90"` instead',
	function(value)
		cdialect "gnu90"
	end,
	function(value)
		cdialect "Default"
	end)

	api.deprecateValue("flags", "C99",   'Use `cdialect "gnu99"` instead',
	function(value)
		cdialect "gnu99"
	end,
	function(value)
		cdialect "Default"
	end)

	api.deprecateValue("flags", "C11",   'Use `cdialect "gnu11"` instead',
	function(value)
		cdialect "gnu11"
	end,
	function(value)
		cdialect "Default"
	end)


	-- 13 April 2017

	api.deprecateValue("flags", "WinMain", 'Use `entrypoint "WinMainCRTStartup"` instead',
	function(value)
		entrypoint "WinMainCRTStartup"
	end,
	function(value)
		entrypoint "mainCRTStartup"
	end)

	-- 31 October 2017

	api.deprecateValue("flags", "StaticRuntime", 'Use `staticruntime "On"` instead',
	function(value)
		staticruntime "On"
	end,
	function(value)
		staticruntime "Default"
	end)

	-- 08 April 2018

	api.deprecateValue("flags", "NoFramePointer", 'Use `omitframepointer "On"` instead.',
	function(value)
		omitframepointer("On")
	end,
	function(value)
		omitframepointer("Default")
	end)

-----------------------------------------------------------------------------
--
-- Install Premake's default set of command line arguments.
--
-----------------------------------------------------------------------------

	newoption
	{
		category	= "compilers",
		trigger     = "cc",
		value       = "VALUE",
		description = "Choose a C/C++ compiler set",
		allowed = {
			{ "clang", "Clang (clang)" },
			{ "gcc", "GNU GCC (gcc/g++)" },
			{ "mingw", "MinGW GCC (gcc/g++)" },
			{ "msc-v80", "Microsoft compiler (Visual Studio 2005)" },
			{ "msc-v90", "Microsoft compiler (Visual Studio 2008)" },
			{ "msc-v100", "Microsoft compiler (Visual Studio 2010)" },
			{ "msc-v110", "Microsoft compiler (Visual Studio 2012)" },
			{ "msc-v120", "Microsoft compiler (Visual Studio 2013)" },
			{ "msc-v140", "Microsoft compiler (Visual Studio 2015)" },
			{ "msc-v141", "Microsoft compiler (Visual Studio 2017)" },
			{ "msc-v142", "Microsoft compiler (Visual Studio 2019)" },
			{ "msc-v143", "Microsoft compiler (Visual Studio 2022)" },
			function (name)
				local toolset, version = p.tools.canonical(name)
				return toolset
			end
		}
	}

	newoption
	{
		category	= "compilers",
		trigger     = "dotnet",
		value       = "VALUE",
		description = "Choose a .NET compiler set",
		allowed = {
			{ "msnet",   "Microsoft .NET (csc)" },
			{ "mono",    "Novell Mono (mcs)"    },
			{ "pnet",    "Portable.NET (cscc)"  },
		}
	}

	newoption
	{
		trigger     = "fatal",
		description = "Treat warnings from project scripts as errors"
	}

    newoption
	{
		trigger     = "debugger",
		description = "Start MobDebug remote debugger. Works with ZeroBrane Studio"
	}

	newoption
	{
		trigger     = "file",
		value       = "FILE",
		description = "Read FILE as a Premake script; default is 'premake5.lua'"
	}

	newoption
	{
		trigger     = "help",
		description = "Display this information"
	}

	newoption
	{
		trigger     = "verbose",
		description = "Generate extra debug text output"
	}

	newoption
	{
		trigger = "interactive",
		description = "Interactive command prompt"
	}

	newoption
	{
		trigger     = "os",
		value       = "VALUE",
		description = "Generate files for a different operating system",
		allowed = {
			{ "aix",      "IBM AIX" },
			{ "bsd",      "OpenBSD, NetBSD, or FreeBSD" },
			{ "haiku",    "Haiku" },
			{ "hurd",     "GNU/Hurd" },
			{ "ios",      "iOS" },
			{ "linux",    "Linux" },
			{ "macosx",   "Apple Mac OS X" },
			{ "solaris",  "Solaris" },
			{ "uwp",      "Microsoft Universal Windows Platform"},
			{ "windows",  "Microsoft Windows" },
		}
	}

	local function getArchs()
		local keys={}
		for key,_ in pairs(premake.field.get("architecture").allowed) do
			if type(key) ~= "number" then
				table.insert(keys, { key, "" })
			end
		end
		return keys
	end

	newoption
	{
		trigger     = "arch",
		value       = "VALUE",
		description = "Generate files for a different architecture",
		allowed = getArchs()
	}

	newoption
	{
		trigger     = "shell",
		value       = "VALUE",
		description = "Select shell (for command token substitution)",
		allowed = {
			{ "cmd", "Windows command shell" },
			{ "posix", "For posix shells" },
		}
	}

	newoption
	{
		trigger     = "scripts",
		value       = "PATH",
		description = "Search for additional scripts on the given path"
	}

	newoption
	{
		trigger     = "systemscript",
		value       = "FILE",
		description = "Override default system script (premake5-system.lua)"
	}

	newoption
	{
		trigger     = "version",
		description = "Display version information"
	}

	if http ~= nil then
		newoption {
			trigger = "insecure",
			description = "Forfeit SSH certification checks."
		}
	end


-----------------------------------------------------------------------------
--
-- Set up the global environment for the systems I know about. I would like
-- to see at least some if not all of this moved into add-ons in the future.
--
-----------------------------------------------------------------------------

	characterset "Default"
	clr "Off"
	editorintegration "Off"
	exceptionhandling "Default"
	rtti "Default"
	symbols "Default"
	nugetsource "https://api.nuget.org/v3/index.json"

	-- Setting a default language makes some validation easier later

	language "C++"

	-- Use Posix-style target naming by default, since it is the most common.

	filter { "kind:SharedLib" }
		targetprefix "lib"
		targetextension ".so"

	filter { "kind:StaticLib" }
		targetprefix "lib"
		targetextension ".a"

	-- Add variations for other Posix-like systems.

	filter { "system:darwin", "kind:WindowedApp" }
		targetextension ".app"

	filter { "system:darwin", "kind:SharedLib" }
		targetextension ".dylib"

	filter { "system:darwin", "kind:SharedLib", "sharedlibtype:OSXBundle" }
		targetprefix ""
		targetextension ".bundle"

	filter { "system:darwin", "kind:SharedLib", "sharedlibtype:OSXFramework" }
		targetprefix ""
		targetextension ".framework"

	filter { "system:darwin", "kind:SharedLib", "sharedlibtype:XCTest" }
		targetprefix ""
		targetextension ".xctest"

	-- Windows and friends.

	filter { "system:Windows or language:C# or language:F#", "kind:ConsoleApp or WindowedApp" }
		targetextension ".exe"

	filter { "system:Windows", "kind:SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	filter { "system:Windows", "kind:StaticLib" }
		targetprefix ""
		targetextension ".lib"

	filter { "language:C# or language:F#", "kind:SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".dll"

	filter { "kind:SharedLib", "system:not Windows" }
		pic "On"

	filter { "system:darwin" }
		toolset "clang"

	filter { "platforms:Win32" }
		architecture "x86"

	filter { "platforms:Win64" }
		architecture "x86_64"

	filter {}
