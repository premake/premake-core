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

	premake.root = configset.new()
	local root = premake.root


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

	configset.addblock(root, { "SharedLib" })
	
		configset.addvalue(root, "targetprefix", "lib")
		configset.addvalue(root, "targetextension", ".so")

	configset.addblock(root, { "StaticLib" })
	
		configset.addvalue(root, "targetprefix", "lib")
		configset.addvalue(root, "targetextension", ".a")


--
-- Add variations for other Posix-like systems.
--

	configset.addblock(root, { "MacOSX", "SharedLib" })
	
		configset.addvalue(root, "targetextension", ".dylib")

	configset.addblock(root, { "PS3", "ConsoleApp" })
	
		configset.addvalue(root, "targetextension", ".elf")


--
-- Windows and friends.
--

	configset.addblock(root, { "Windows", "ConsoleApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "Windows", "WindowedApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "Windows", "SharedLib" })
	
		configset.addvalue(root, "targetprefix", "")
		configset.addvalue(root, "targetextension", ".dll")
		configset.addvalue(root, "implibextension", ".lib")

	configset.addblock(root, { "Windows", "StaticLib" })
	
		configset.addvalue(root, "targetprefix", "")
		configset.addvalue(root, "targetextension", ".lib")

	configset.addblock(root, { "Xbox360", "ConsoleApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "Xbox360", "WindowedApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "Xbox360", "SharedLib" })
	
		configset.addvalue(root, "targetprefix", "")
		configset.addvalue(root, "targetextension", ".dll")
		configset.addvalue(root, "implibextension", ".lib")

	configset.addblock(root, { "Xbox360", "StaticLib" })
	
		configset.addvalue(root, "targetprefix", "")
		configset.addvalue(root, "targetextension", ".lib")


--
-- .NET languages always use Windows-style naming.
--

	configset.addblock(root, { "C#", "ConsoleApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "C#", "WindowedApp" })
	
		configset.addvalue(root, "targetextension", ".exe")

	configset.addblock(root, { "C#", "SharedLib" })
	
		configset.addvalue(root, "targetprefix", "")
		configset.addvalue(root, "targetextension", ".dll")
