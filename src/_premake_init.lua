--
-- _premake_init.lua
--
-- Prepares the runtime environment for the add-ons and user project scripts.
--
-- Copyright (c) 2012 Jason Perkins and the Premake project
--


--
-- Set up the global environment for the systems I know about. I would like to see
-- at least some if not all of this moved into add-ons in the future.
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

	configuration { "Windows or Xbox360 or C#", "ConsoleApp or WindowedApp" }
		targetextension ".exe"

	configuration { "Windows or Xbox360 or C#", "SharedLib" }
		targetprefix ""
		targetextension ".dll"
		implibextension ".lib"

	configuration { "Windows or Xbox360 or C#", "StaticLib" }
		targetprefix ""
		targetextension ".lib"
