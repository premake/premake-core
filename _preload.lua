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
	p.ANDROIDPROJ = "androidproj"

	api.addAllowed("system", p.ANDROID)
	api.addAllowed("architecture", { "armv5", "armv7", "aarach64", "mips", "mips64", "arm" })
	api.addAllowed("vectorextensions", { "NEON", "MXU" })
	api.addAllowed("flags", { "Thumb" })
	api.addAllowed("kind", p.ANDROIDPROJ)

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
	
	if _ACTION >= "vs2015" then
		api.register {
			name = "toolchainversion",
			scope = "config",
			kind = "string",
			allowed = {
				"4.9", -- NDK GCC versions
				"3.6", -- NDK clang versions
			},
		}
	else
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
				"3.6",
			},
		}
	end

	if _ACTION >= "vs2015" then
		api.register {
			name = "stl",
			scope = "config",
			kind = "string",
			allowed = {
				"minimal c++ (system)",
				"c++ static",
				"c++ shared",
				"stlport static",
				"stlport shared",
				"gnu stl static",
				"gnu stl shared",
				"llvm libc++ static",
				"llvm libc++ shared",
			},
		}
	else
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
	end

	api.register {
		name = "thumbmode",
		scope = "config",
		kind = "string",
		allowed = {
			"thumb",
			"arm",
			"disabled",
		},
	}