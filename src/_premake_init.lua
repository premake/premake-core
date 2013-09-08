--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--


--
-- Set the default module search paths. Modules will generally live in a
-- folder of the same name: ninja/ninja.lua. The search order is the same
-- as what is specified here.
--

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


--
-- Set up the global environment for the systems I know about. I would like to see
-- at least some if not all of this moved into add-ons in the future.
--
-- Use Posix-style target naming by default, since it is the most common.
--

	configuration { "SharedLib" }
		targetprefix "lib"
		targetextension ".so"

	configuration { "StaticLib" }
		targetprefix "lib"
		targetextension ".a"


--
-- Add variations for other Posix-like systems.
--

	configuration { "MacOSX", "SharedLib" }
		targetextension ".dylib"

	configuration { "PS3", "ConsoleApp" }
		targetextension ".elf"


--
-- Windows and friends.
--

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


--
-- Install Premake's default set of command line arguments.
--

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
		description = "Read FILE as a Premake script; default is 'premake4.lua'"
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
