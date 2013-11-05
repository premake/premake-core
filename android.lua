
--
-- Create an android namespace to isolate the additions
--
	premake.extensions.android = {}

	local android = premake.extensions.android
	local vstudio = premake.vstudio
	local project = premake.project
	local api = premake.api

	android.support_url = "https://bitbucket.org/premakeext/android/wiki/Home"

	android.printf = function( msg, ... )
		printf( "[android] " .. msg, ...)
	end

	android.printf( "Premake Android Extension (" .. android.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/vstudio/?.lua;".. package.path


--
-- Register the Android extension
--

	premake.ANDROID = "android"

	api.addAllowed("system", premake.ANDROID)
	api.addAllowed("architecture", { "x86", "arm", "armv5", "armv7", "mips" })
	api.addAllowed("vectorextensions", { "NEON", "MXU" })
	api.addAllowed("flags", {
		"EnableThumb",
--		"EnablePIC",
--		"DisablePIC",
--		"EnableStrictAliasing",
--		"DisableStrictAliasing",
		"SoftwareFloat",
		"HardwareFloat",
--		"LittleEndian",
--		"BigEndian"
	})

	-- TODO: can I api.addAllowed() a key-value pair?
	local os = premake.fields["os"];
	if os ~= nil then
		table.insert(sys.allowed, { "android",  "Android" })
	end

	premake.platforms.Android = { 
		cfgsuffix       = "android",
		iscrosscompiler = true,
	}


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
			"4.4.3", -- NDK GCC versions
			"4.6",
			"4.7",
			"4.8",
			"3.1", -- NDK clang versions
			"3.2",
			"3.3",
		},
	}


--
-- 'require' the vs-android .vcxproj code.
--

	require( "vsandroid_vcxproj" )
	android.printf( "Loaded vs-android support 'vsandroid_vcxproj.lua'", v )
