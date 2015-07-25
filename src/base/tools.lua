---
-- tools.lua
-- Work with Premake's collection of tool adapters.
-- Author Jason Perkins
-- Copyright (c) 2015 Jason Perkins and the Premake project
---

	local p = premake
	p.tools = {}


---
-- Given a toolset identifier (e.g. "gcc" or "gcc-4.8") returns the
-- corresponding tool adapter and the version, if one was provided.
--
-- @param identifier
--    A toolset identifier composed of two parts: the toolset name,
--    which should match of the name of the adapter object ("gcc",
--    "clang", etc.) in the premake.tools namespace, and and optional
--    version number, separated by a dash.
--
--     To make things more intuitive for Visual Studio users, supports
--     identifiers like "v100" to represent the v100 Microsoft platform
--     toolset.
-- @return
--    If successful, returns the toolset adapter object. If a version
--    was specified as part of the identifier, that is returned as a
--    second return value. If no corresponding tool adapter exists,
--    returns nil.
---

	function p.tools.canonical(identifier)
		local parts
		if identifier:startswith("v") then
			parts = { "msc", identifier:sub(2) }
		elseif identifier:startswith("llvm-vs") then -- support LLVM toolset in VS
			parts = { "msc", "LLVM-vs" .. identifier:sub(8) }
		else
			parts = identifier:explode("-")

			-- hack to check for LLVM toolsets, which would be corrupted by the previous line
			if parts[1] == "msc" and parts[2] == "llvm" and parts[3]:startswith("vs") then
				parts = { parts[1], "LLVM-" .. parts[3] }
			end
		end
		return p.tools[parts[1]], parts[2]
	end
