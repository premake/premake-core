
--
-- Create a Android namespace to isolate the additions
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

	local sys = premake.fields["system"];
	if sys ~= nil and sys.allowed.android == nil then
		table.insert( sys.allowed, premake.ANDROID )
	end

	local os = premake.fields["os"];
--	if os ~= nil and os.allowed.android == nil then
	if os ~= nil then
		table.insert( sys.allowed, { "android",  "Android" } )
	end

	local arch = premake.fields["architecture"];
	if arch ~= nil then
		if arch.allowed["armv5"] == nil then
			table.insert( arch.allowed, "armv5" )
		end
		if arch.allowed["armv7"] == nil then
			table.insert( arch.allowed, "armv7" )
		end
		if arch.allowed["mips"] == nil then
			table.insert( arch.allowed, "mips" )
		end
	end

	local vectorext = premake.fields["vectorextensions"];
	if vectorext ~= nil and vectorext.allowed.NEON == nil then
		table.insert( vectorext.allowed, "NEON" )
	end

	if premake.platforms ~= nil then
		premake.platforms.Android = { 
			cfgsuffix       = "android",
			iscrosscompiler = true,
		}
	end


--
-- Add Android-specific flags
--

	local function addflags(newflags)
		local flags = premake.fields["flags"];
		if flags ~= nil then
			for k,v in pairs(newflags) do
				if flags.allowed[v] == nil then
					table.insert( flags.allowed, v )
				end
			end
		end
	end

	-- TODO: refactor these into independent options?
	addflags {
		"EnableThumb",
--		"EnablePIC",
--		"DisablePIC",
--		"EnableStrictAliasing",
--		"DisableStrictAliasing",
		"SoftwareFloat",
		"HardwareFloat",
--		"LittleEndian",
--		"BigEndian"
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

	-- TODO: no support for integer properties!
--	api.register {
--		name = "androidapilevel",
--		scope = "config",
--		kind = "integer",
--	}


--
-- 'require' the vs-android .vcxproj code.
--

	require( "vsandroid_vcxproj" )
	android.printf( "Loaded vs-android support 'vsandroid_vcxproj.lua'", v )
