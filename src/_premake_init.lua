--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local api = premake.api

	local DOC_URL = "https://bitbucket.org/premake/premake-dev/wiki/"


-----------------------------------------------------------------------------
--
-- Prepare the global environment.
--
-----------------------------------------------------------------------------

	-- Set the default module search paths. Modules will generally live in
	-- a folder of the same name: ninja/ninja.lua. The search order is the
	-- same as what is specified here.

	local home = os.getenv("HOME") or os.getenv("USERPROFILE")

	local packagePaths = {
		path.join(home, ".premake/?/?.lua"),
		"./modules/?/?.lua",
		path.join(path.getdirectory(_PREMAKE_COMMAND), "modules/?/?.lua"),
		path.join(home, "Library/Application Support/Premake/?/?.lua"),
		"/usr/local/share/premake/?/?.lua",
		"/usr/share/premake/?/?.lua",
	}

	package.path = table.concat(packagePaths, ";")


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
		name = "basedir",
		scope = "project",
		kind = "path"
	}

	api.register {
		name = "buildaction",
		scope = "config",
		kind = "string",
		allowed = {
			"Compile",
			"Component",
			"Copy",
			"Embed",
			"Form",
			"None",
			"UserControl",
		},
	}

	api.register {
		name = "buildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "buildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "buildoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "buildoutputs",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "buildrule",     -- DEPRECATED
		scope = "config",
		kind = "object",
		tokens = true,
	}

	api.register {
		name = "cleancommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "configmap",
		scope = "config",
		kind = "key-array"
	}

	api.register {
		name = "configurations",
		scope = "project",
		kind = "string-list",
	}

	api.register {
		name = "copylocal",
		scope = "config",
		kind = "mixed-list",
		tokens = true,
	}

	api.register {
		name = "debugargs",
		scope = "config",
		kind = "string-list",
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
		kind = "string-list",
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
		name = "defines",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "dependson",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "deploymentoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	-- For backward compatibility, excludes() is now an alias for removefiles()
	function excludes(value)
		removefiles(value)
	end

	api.register {
		name = "filename",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "files",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "flags",
		scope = "config",
		kind  = "string-list",
		allowed = {
			"Component",           -- DEPRECATED
			"DebugEnvsDontMerge",
			"DebugEnvsInherit",
			"EnableSSE",           -- DEPRECATED
			"EnableSSE2",          -- DEPRECATED
			"ExcludeFromBuild",
			"ExtraWarnings",       -- DEPRECATED
			"FatalWarnings",
			"FloatFast",           -- DEPRECATED
			"FloatStrict",         -- DEPRECATED
			"LinkTimeOptimization",
			"Managed",
			"MFC",
			"MultiProcessorCompile",
			"NativeWChar",         -- DEPRECATED
			"No64BitChecks",
			"NoCopyLocal",
			"NoEditAndContinue",
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
			"Optimize",            -- DEPRECATED
			"OptimizeSize",        -- DEPRECATED
			"OptimizeSpeed",       -- DEPRECATED
			"ReleaseRuntime",
			"SEH",
			"StaticRuntime",
			"Symbols",
			"Unicode",
			"Unsafe",
			"WinMain",
		},
		aliases = {
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
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "forceusings",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "framework",
		scope = "project",
		kind = "string",
		allowed = {
			"1.0",
			"1.1",
			"2.0",
			"3.0",
			"3.5",
			"4.0",
			"4.5",
		},
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
		kind = "string-list",
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
		kind = "directory-list",
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
		kind = "directory-list",
		tokens = true,
	}

	api.register {
		name = "linkoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "links",
		scope = "config",
		kind = "mixed-list",
		tokens = true,
	}

	api.register {
		name = "location",
		scope = "project",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "makesettings",
		scope = "config",
		kind = "string-list",
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
			"Size",
			"Speed",
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
		kind = "string-list",
	}

	api.register {
		name = "postbuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "prebuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "prelinkcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "rebuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "resdefines",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "resincludedirs",
		scope = "config",
		kind = "directory-list",
		tokens = true,
	}

	api.register {
		name = "resoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "startproject",
		scope = "solution",
		kind = "string",
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
		allowed = {
			"clang",
			"gcc",
			"msc",
			"snc",
		},
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
			"SSE",
			"SSE2",
		}
	}

	api.register {
		name = "vpaths",
		scope = "project",
		kind = "key-path-list",
	}



-----------------------------------------------------------------------------
--
-- Handlers for deprecated fields and values.
--
-----------------------------------------------------------------------------

	-- 09 Apr 2013

	api.deprecateField("buildrule", function(value)
		if value.description then
			buildmessage(value.description)
		end
		buildcommands(value.commands)
		buildoutputs(value.outputs)
		return DOC_URL ..  "Custom_Build_Commands"
	end)

	-- 17 Jun 2013

	api.deprecateValue("flags", "Component", function(value)
		buildaction "Component"
		return DOC_URL .. "buildaction"
	end)

	-- 26 Sep 2013

	api.deprecateValue("flags", { "EnableSSE", "EnableSSE2" }, function(value)
		vectorextensions(value:sub(7))
		return DOC_URL .. "vectorextensions"
	end)

	api.deprecateValue("flags", { "FloatFast", "FloatStrict" }, function(value)
		floatingpoint(value:sub(6))
		return DOC_URL ..  "floatingpoint"
	end)

	api.deprecateValue("flags", { "NativeWChar", "NoNativeWChar" }, function(value)
		local map = { NativeWChar = "On", NoNativeWChar = "Off" }
		nativewchar(map[value] or "Default")
		return DOC_URL .. "nativewchar"
	end)

	api.deprecateValue("flags", { "Optimize", "OptimizeSize", "OptimizeSpeed" }, function(value)
		local map = { Optimize = "On", OptimizeSize = "Size", OptimizeSpeed = "Speed" }
		optimize (map[value] or "Off")
		return DOC_URL .. "optimize"
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
		value       = "path",
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

	-- Use Posix-style target naming by default, since it is the most common.

	configuration { "SharedLib" }
		targetprefix "lib"
		targetextension ".so"

	configuration { "StaticLib" }
		targetprefix "lib"
		targetextension ".a"

	-- Add variations for other Posix-like systems.

	configuration { "MacOSX", "SharedLib" }
		targetextension ".dylib"

	configuration { "PS3", "ConsoleApp" }
		targetextension ".elf"

	-- Windows and friends.

	configuration { "Windows or C#", "ConsoleApp or WindowedApp" }
		targetextension ".exe"

	configuration { "Xbox360", "ConsoleApp or WindowedApp" }
		targetextension ".exe"

	configuration { "Windows or Xbox360 or C#", "SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	configuration { "Windows or Xbox360 or C#", "StaticLib" }
		targetprefix ""
		targetextension ".lib"
