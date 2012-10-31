--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	local configset = premake.configset


--
-- Create a "root" configuration set, to hold the global configuration. Values
-- that are added to this set become available for all add-ons, solution, projects,
-- and on down the line.
--

	configset.root = configset.new()
	local root = configset.root


--
-- Set up the global environment for the systems I know about. I would like to see
-- at least some if not all of this moved into add-ons in the future.
--
-- TODO: use the same configuration API as the user project scripts, once they
-- have been ported, like:
--
--     configuration { "Windows or Xbox360", "SharedLib" }
--         targetprefix ""
--         targetextension ".dll"
--         implibextension ".lib"
--

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

	configuration { "Windows", "ConsoleApp" }
		targetextension ".exe"

	configuration { "Windows", "WindowedApp" }
		targetextension ".exe"

	configuration { "Windows", "SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	configuration { "Windows", "StaticLib" }
		targetprefix ""
		targetextension ".lib"
	
	configuration { "Xbox360", "ConsoleApp" }
		targetextension ".exe"
	
	configuration { "Xbox360", "WindowedApp" }
		targetextension ".exe"

	configuration { "Xbox360", "SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	configuration { "Xbox360", "StaticLib" }
		targetprefix ""
		targetextension ".lib"		


--
-- .NET languages always use Windows-style naming.
--

	configuration { "C#", "ConsoleApp" }
		targetextension ".exe"

	configuration { "C#", "WindowedApp" }
		targetextension ".exe"

	configuration { "C#", "SharedLib" }
		targetprefix ""
		targetextension ".dll"
