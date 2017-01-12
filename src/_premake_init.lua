--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
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
		allowed = {
			"Application",
			"Compile",
			"Component",
			"Copy",
			"Embed",
			"Form",
			"None",
			"Resource",
			"UserControl",
		},
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
		pathVars = true,
	}

	api.register {
		name = "buildinputs",
		scope = "config",
		kind = "list:path",
		tokens = true,
		pathVars = true,
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
		}
	}

	api.register {
		name = "compilebuildoutputs",
		scope = "config",
		kind = "boolean"
	}

	api.register {
		name = "configmap",
		scope = "project",
		kind = "list:keyed:array:string",
	}

	api.register {
		name = "configfile",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "configurations",
		scope = "project",
		kind = "list:string",
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
	}

	api.register {
		name = "debugcommand",
		scope = "config",
		kind = "path",
		tokens = true,
		pathVars = true,
	}

	api.register {
		name = "debugconnectcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
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
		name = "debugextendedprotocol",
		scope = "config",
		kind = "boolean",
	}

	api.register {
		name = "debugformat",
		scope = "config",
		kind = "string",
		allowed = {
			"c7",
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
		}
	}

	api.register {
		name = "debugpathmap",
		scope = "config",
		kind = "list:keyed:path",
		tokens = true,
	}

	api.register {
		name = "debugport",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "debugremotehost",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "debugsearchpaths",
		scope = "config",
		kind = "list:path",
		tokens = true,
	}

	api.register {
		name = "debugstartupcommands",
		scope = "config",
		kind = "list:string",
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
	}

	api.register {
		name = "dependson",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "deploymentoptions",
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
			"SEH"
		},
	}

	api.register {
		name = "enablewarnings",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "endian",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Little",
			"Big",
		},
	}

	api.register {
		name = "entrypoint",
		scope = "config",
		kind = "string",
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
			"NoExceptions",        -- DEPRECATED
			"NoFramePointer",
			"NoImplicitLink",
			"NoImportLib",
			"NoIncrementalLink",
			"NoManifest",
			"NoMinimalRebuild",
			"NoNativeWChar",       -- DEPRECATED
			"NoPCH",
			"NoRuntimeChecks",
			"NoRTTI",              -- DEPRECATED
			"NoBufferSecurityCheck",
			"NoWarnings",          -- DEPRECATED
			"OmitDefaultLibrary",
			"Optimize",            -- DEPRECATED
			"OptimizeSize",        -- DEPRECATED
			"OptimizeSpeed",       -- DEPRECATED
			"RelativeLinks",
			"ReleaseRuntime",      -- DEPRECATED
			"SEH",                 -- DEPRECATED
			"ShadowedVariables",
			"StaticRuntime",
			"Symbols",             -- DEPRECATED
			"UndefinedIdentifiers",
			"Unicode",             -- DEPRECATED
			"Unsafe",              -- DEPRECATED
			"WinMain",
			"WPF",
			"C++11",
			"C++14",
			"C90",
			"C99",
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
		name = "fpu",
		scope = "config",
		kind = "string",
		allowed = {
			"Software",
			"Hardware",
		}
	}

	api.register {
		name = "dotnetframework",
		scope = "config",
		kind = "string",
	}

	api.register {
		name = "gccprefix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "ignoredefaultlibraries",
		scope = "config",
		kind = "list:mixed",
		tokens = true,
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
		},
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
		scope = "project",
		kind = "list:string",
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
		name = "startproject",
		scope = "workspace",
		kind = "string",
		tokens = true,
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
		name = "symbols",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
			"FastLink",    -- Visual Studio 2015+ only, considered 'On' for all other cases.
		},
	}

	api.register {
		name = "symbolspath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "sysincludedirs",
		scope = "config",
		kind = "list:directory",
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
			"linux",
			"macosx",
			"solaris",
			"wii",
			"windows",
			"xbox360",
		},
	}

	api.register {
		name = "systemversion",
		scope = "project",
		kind = "string",
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
				return value
			end
		end,
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
			"Extra",
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
	api.alias("configfile", "configFile")
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

	-- 09 Apr 2013

	api.deprecateField("buildrule", nil,
	function(value)
		if value.description then
			buildmessage(value.description)
		end
		buildcommands(value.commands)
		buildoutputs(value.outputs)
	end)


	-- 17 Jun 2013

	api.deprecateValue("flags", "Component", nil,
	function(value)
		buildaction "Component"
	end)


	-- 26 Sep 2013

	api.deprecateValue("flags", { "EnableSSE", "EnableSSE2" }, nil,
	function(value)
		vectorextensions(value:sub(7))
	end,
	function(value)
		vectorextensions "Default"
	end)


	api.deprecateValue("flags", { "FloatFast", "FloatStrict" }, nil,
	function(value)
		floatingpoint(value:sub(6))
	end,
	function(value)
		floatingpoint "Default"
	end)


	api.deprecateValue("flags", { "NativeWChar", "NoNativeWChar" }, nil,
	function(value)
		local map = { NativeWChar = "On", NoNativeWChar = "Off" }
		nativewchar(map[value] or "Default")
	end,
	function(value)
		nativewchar "Default"
	end)


	api.deprecateValue("flags", { "Optimize", "OptimizeSize", "OptimizeSpeed" }, nil,
	function(value)
		local map = { Optimize = "On", OptimizeSize = "Size", OptimizeSpeed = "Speed" }
		optimize (map[value] or "Off")
	end,
	function(value)
		optimize "Off"
	end)

	api.deprecateValue("flags", { "ReleaseRuntime" }, nil,
	function(value)
		runtime 'Release'
	end,
	function(value)
	end)

	api.deprecateValue("flags", { "Optimise", "OptimiseSize", "OptimiseSpeed" }, nil,
	function(value)
		local map = { Optimise = "On", OptimiseSize = "Size", OptimiseSpeed = "Speed" }
		optimize (map[value] or "Off")
	end,
	function(value)
		optimize "Off"
	end)


	api.deprecateValue("flags", { "ExtraWarnings", "NoWarnings" }, nil,
	function(value)
		local map = { ExtraWarnings = "Extra", NoWarnings = "Off" }
		warnings (map[value] or "Default")
	end,
	function(value)
		warnings "Default"
	end)


	-- 10 Nov 2014

	api.deprecateValue("flags", "Managed", nil,
	function(value)
		clr "On"
	end,
	function(value)
		clr "Off"
	end)


	api.deprecateValue("flags", "NoEditAndContinue", nil,
	function(value)
		editandcontinue "Off"
	end,
	function(value)
		editandcontinue "On"
	end)


	api.deprecateValue("flags", "NoExceptions", 'Use `exceptionhandling "Off"` instead',
	function(value)
		exceptionhandling "Off"
	end,
	function(value)
		exceptionhandling "On"
	end)


	api.deprecateValue("flags", "NoRTTI", 'Use `rtti "Off"` instead',
	function(value)
		rtti "Off"
	end,
	function(value)
		rtti "On"
	end)

	api.deprecateValue("flags", "SEH", 'Use `exceptionhandling "SEH"` instead',
	function(value)
		exceptionhandling "SEH"
	end,
	function(value)
		exceptionhandling "Default"
	end)

	api.deprecateValue("flags", "Unsafe", 'Use `clr "Unsafe"` instead',
	function(value)
		clr "Unsafe"
	end,
	function(value)
		clr "On"
	end)

	-- 18 Dec 2015

	api.deprecateValue("flags", "Unicode", 'Use `characterset "Unicode"` instead',
	function(value)
		characterset "Unicode"
	end,
	function(value)
		characterset "Default"
	end)

	-- 21 June 2016

	api.deprecateValue("flags", "Symbols", 'Use `symbols "On"` instead',
	function(value)
		symbols "On"
	end,
	function(value)
		symbols "Default"
	end)



-----------------------------------------------------------------------------
--
-- Install Premake's default set of command line arguments.
--
-----------------------------------------------------------------------------

	newoption
	{
		trigger     = "cc",
		value       = "VALUE",
		description = "Choose a C/C++ compiler set",
		allowed = {
			{ "clang", "Clang (clang)" },
			{ "gcc", "GNU GCC (gcc/g++)" },
		}
	}

	newoption
	{
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
			{ "linux",    "Linux" },
			{ "macosx",   "Apple Mac OS X" },
			{ "solaris",  "Solaris" },
			{ "windows",  "Microsoft Windows" },
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

	filter { "system:MacOSX", "kind:SharedLib" }
		targetextension ".dylib"

	-- Windows and friends.

	filter { "system:Windows or language:C#", "kind:ConsoleApp or WindowedApp" }
		targetextension ".exe"

	filter { "system:Xbox360", "kind:ConsoleApp or WindowedApp" }
		targetextension ".exe"

	filter { "system:Windows or Xbox360", "kind:SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	filter { "system:Windows or Xbox360", "kind:StaticLib" }
		targetprefix ""
		targetextension ".lib"

	filter { "language:C#", "kind:SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".dll"

	filter { "kind:SharedLib", "system:not Windows" }
		pic "On"

	filter { "system:macosx" }
		toolset "clang"

	filter {}
