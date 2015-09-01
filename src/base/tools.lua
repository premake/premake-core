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
		if identifier:startswith("v") then -- TODO: this should be deprecated?
			parts = { "msc", identifier }
		else
			parts = identifier:explode("-", true, 1)

			-- couple of little hacks here to fix up version names
			if parts[2] ~= nil then
				-- 'msc-100' is accepted, but the code expects 'v100'
				if parts[1] == "msc" and tonumber(parts[2]:sub(1,3)) ~= nil then
					parts[2] = "v" .. parts[2]
				end

				-- perform case-correction of the LLVM toolset
				if parts[2]:startswith("llvm-vs") then
					parts[2] = "LLVM-" .. parts[2]:sub(6)
				end
			end
		end
		return p.tools[parts[1]], parts[2]
	end
