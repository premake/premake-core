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

	api.addAllowed("system", p.ANDROID)
	api.addAllowed("architecture", { "armv5", "armv7", "aarch64", "mips", "mips64", "arm" })
	api.addAllowed("vectorextensions", { "NEON", "MXU" })
	api.addAllowed("exceptionhandling", {"UnwindTables"})
	api.addAllowed("flags", { "Thumb" })
	api.addAllowed("kind", p.PACKAGING)


	premake.action._list["vs2015"].valid_kinds = table.join(premake.action._list["vs2015"].valid_kinds, { p.PACKAGING })
	premake.action._list["vs2017"].valid_kinds = table.join(premake.action._list["vs2017"].valid_kinds, { p.PACKAGING })
	premake.action._list["vs2019"].valid_kinds = table.join(premake.action._list["vs2019"].valid_kinds, { p.PACKAGING })
	
	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { "android",  "Android" })
	end

	-- add system tags for android.
	os.systemTags[p.ANDROID] = { "android", "mobile" }

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
			"3.6",
			"3.8",
			"5.0",
		},
	}

	api.register {
		name = "stl",
		scope = "config",
		kind = "string",
		allowed = {
			"none",
			"gabi++",
			"stlport",
			"gnu",
			"libc++",
		},
	}

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

	api.register {
		name = "androidapplibname",
		scope = "config",
		kind = "string"
	}

	return function(cfg)
		return (cfg.system == p.ANDROID)
	end
