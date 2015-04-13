--
-- Name:        android/_preload.lua
-- Purpose:     Define the Android API's.
-- Author:      Manu Evans
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

	local p = premake
	local api = p.api

--
-- Register the Android extension
--

	p.ANDROID = "android"

	api.addAllowed("system", p.ANDROID)
	api.addAllowed("architecture", { "armv5", "armv7", "aarach64", "mips", "mips64" })
	api.addAllowed("vectorextensions", { "NEON", "MXU" })
	api.addAllowed("flags", { "Thumb" })

	-- TODO: can I api.addAllowed() a key-value pair?
	local os = p.fields["os"];
	if os ~= nil then
		table.insert(sys.allowed, { "android",  "Android" })
	end


--
-- Register Android properties
--

	api.register {
		name = "floatabi",
		scope = "config",
		kind = "string",
		allowed = {
			"soft",
			"softfp",
			"hard",
		},
	}

	api.register {
		name = "androidapilevel",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "toolchainversion",
		scope = "config",
		kind = "string",
		allowed = {
			"4.6", -- NDK GCC versions
			"4.8",
			"4.9",
			"3.4", -- NDK clang versions
			"3.5",
		},
	}

	api.register {
		name = "stl",
		scope = "config",
		kind = "string",
		allowed = {
			"none",
			"minimal",
			"stdc++",
			"stlport",
		},
	}
