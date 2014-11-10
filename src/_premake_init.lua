--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local api = premake.api

	local DOC_URL = "See https://bitbucket.org/premake/premake-dev/wiki/"


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
			"x32",
			"x64",
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
	}

	api.alias("buildcommands", "buildCommands")


	api.register {
		name = "buildDependencies",
		scope = { "rule" },
		kind = "list:string",
		tokens = true,
	}


	api.register {
		name = "buildmessage",
		scope = { "config", "rule" },
		kind = "string",
		tokens = true
	}

	api.alias("buildmessage", "buildMessage")


	api.register {
		name = "buildoptions",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}


	api.register {
		name = "buildoutputs",
		scope = { "config", "rule" },
		kind = "list:path",
		tokens = true,
	}

	api.alias("buildoutputs", "buildOutputs")


	api.register {
		name = "buildinputs",
		scope = "config",
		kind = "list:path",
		tokens = true,
	}

	api.register {
		name = "buildrule",     -- DEPRECATED
		scope = "config",
		kind = "table",
		tokens = true,
	}

	api.register {
		name = "cleancommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "cleanExtensions",
		scope = "config",
		kind = "list:string",
	}

	api.register {
		name = "configmap",
		scope = "config",
		kind = "list:keyed:array:string",
	}

	api.register {
		name = "configFile",
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
	}

	api.register {
		name = "debugcommand",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "debugdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "debugenvs",
		scope = "config",
		kind = "list:string",
		tokens = true,
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
		name = "display",
		scope = "rule",
		kind = "string",
	}


	api.register {
		name = "editAndContinue",
		scope = "config",
		kind = "boolean",
	}


	-- For backward compatibility, excludes() is now an alias for removefiles()
	function excludes(value)
		removefiles(value)
	end


	api.register {
		name = "fileExtension",
		scope = "rule",
		kind = "string",
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
			"Managed",
			"Maps",
			"MFC",
			"MultiProcessorCompile",
			"NativeWChar",         -- DEPRECATED
			"No64BitChecks",
			"NoCopyLocal",
			"NoEditAndContinue",   -- DEPRECATED
			"NoExceptions",
			"NoFramePointer",
			"NoImplicitLink",
			"NoImportLib",
			"NoIncrementalLink",
			"NoManifest",
			"NoMinimalRebuild",
			"NoNativeWChar",       -- DEPRECATED
			"NoPCH",
			"NoRuntimeChecks",
			"NoRTTI",
			"NoBufferSecurityCheck",
			"NoWarnings",          -- DEPRECATED
			"OmitDefaultLibrary",
			"Optimize",            -- DEPRECATED
			"OptimizeSize",        -- DEPRECATED
			"OptimizeSpeed",       -- DEPRECATED
			"ReleaseRuntime",
			"SEH",
			"ShadowedVariables",
			"StaticRuntime",
			"Symbols",
			"UndefinedIdentifiers",
			"Unicode",
			"Unsafe",
			"WinMain",
			"WPF",
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
		name = "framework",
		scope = "config",
		kind = "string",
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
		name = "platforms",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "postbuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "postbuildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "prebuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "prebuildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "prelinkcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "prelinkmessage",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "propertyDefinition",
		scope = "rule",
		kind = "list:table",
	}

	api.register {
		name = "rebuildcommands",
		scope = "config",
		kind = "list:string",
		tokens = true,
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
		name = "rules",
		scope = "project",
		kind = "list:string",
	}

	api.register {
		name = "startproject",
		scope = "solution",
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
		name = "system",
		scope = "config",
		kind = "string",
		allowed = {
			"aix",
			"bsd",
			"haiku",
			"linux",
			"macosx",
			"ps3",
			"solaris",
			"wii",
			"windows",
			"xbox360",
		},
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
			local key = value:lower()
			if premake.tools[key] ~= nil then
				return key
			end
		end,
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
			"SSE",
			"SSE2",
		}
	}

	api.register {
		name = "vpaths",
		scope = "project",
		kind = "list:keyed:list:path",
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
		vectorextension "Default"
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

	api.deprecateValue("flags", "NoEditAndContinue", nil,
	function(value)
		editAndContinue "Off"
	end,
	function(value)
		editAndContinue "On"
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

	editAndContinue "On"

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

	-- PS3 configurations

	filter { "system:PS3" }
		toolset "snc"

	filter { "system:PS3", "kind:ConsoleApp" }
		targetextension ".elf"
