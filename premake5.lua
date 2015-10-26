---
-- Premake 5.x build configuration script
-- Use this script to configure the project with Premake5.
---

--
-- Remember my location; I will need it to locate sub-scripts later.
--

	local corePath = _SCRIPT_DIR


--
-- Disable deprecation warnings for myself, so that older development
-- versions of Premake can be used to bootstrap new builds.
--

	premake.api.deprecations "off"


--
-- Register supporting actions and options.
--

	newaction {
		trigger = "embed",
		description = "Embed scripts in scripts.c; required before release builds",
		execute = function ()
			include (path.join(corePath, "scripts/embed.lua"))
		end
	}


	newaction {
		trigger = "package",
		description = "Creates source and binary packages",
		execute = function ()
			include (path.join(corePath, "scripts/package.lua"))
		end
	}


	newaction {
		trigger = "test",
		description = "Run the automated test suite",
		execute = function ()
			include (path.join(corePath, "scripts/test.lua"))
		end
	}


	newoption {
		trigger     = "test",
		description = "When testing, run only the specified suite or test"
	}


	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}


	newoption {
		trigger = "no-curl",
		description = "Disable Curl 3rd party lib"
	}


	newoption {
		trigger = "no-zlib",
		description = "Disable Zlib/Zip 3rd party lib"
	}

	newoption {
		trigger     = "no-bytecode",
		description = "Don't embed bytecode, but instead use the stripped souce code."
	}

--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to
-- worry about the /scripts argument and all that.
--
-- TODO: defaultConfiguration "Release"
--

	solution "Premake5"
		configurations { "Release", "Debug" }
		location ( _OPTIONS["to"] )

		configuration { "macosx", "gmake" }
			buildoptions { "-mmacosx-version-min=10.4" }
			linkoptions  { "-mmacosx-version-min=10.4" }

	project "Premake5"
		targetname  "premake5"
		language    "C"
		kind        "ConsoleApp"
		flags       { "No64BitChecks", "ExtraWarnings", "StaticRuntime" }
		includedirs { "src/host/lua/src" }

		-- optional 3rd party libraries
		if not _OPTIONS["no-zlib"] then
			includedirs { "contrib/zlib", "contrib/libzip" }
			defines { "PREMAKE_COMPRESSION" }
			links { "zip-lib", "zlib-lib" }
		end
		if not _OPTIONS["no-curl"] then
			includedirs { "contrib/curl/include" }
			defines { "CURL_STATICLIB", "PREMAKE_CURL" }
			links { "curl-lib" }
		end

		files
		{
			"*.txt", "**.lua",
			"src/**.h", "src/**.c",
			"src/host/scripts.c"
		}

		excludes
		{
			"src/host/lua/src/lauxlib.c",
			"src/host/lua/src/lua.c",
			"src/host/lua/src/luac.c",
			"src/host/lua/src/print.c",
			"src/host/lua/**.lua",
			"src/host/lua/etc/*.c"
		}

		configuration "Debug"
			targetdir   "bin/debug"
			defines     "_DEBUG"
			flags       { "Symbols" }
			debugargs   { "--scripts=" .. path.translate(os.getcwd()) .. " test"}
			debugdir    ( os.getcwd() )

		configuration "Release"
			targetdir   "bin/release"
			defines     "NDEBUG"
			flags       { "OptimizeSize" }

		configuration "vs*"
			defines     { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS" }

		configuration "vs2005"
			defines	{"_CRT_SECURE_NO_DEPRECATE" }

		configuration "windows"
			links       { "ole32", "ws2_32" }

		configuration "linux or bsd or hurd"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }
			linkoptions { "-rdynamic" }

		configuration "linux or hurd"
			links       { "dl", "rt" }

		configuration "linux"
			if not _OPTIONS["no-curl"] and os.findlib("ssl") then
				links       { "ssl", "crypto" }
			end

		configuration "macosx"
			defines     { "LUA_USE_MACOSX" }
			links       { "CoreServices.framework" }
			if not _OPTIONS["no-curl"] then
				links   { "Security.framework" }
			end

		configuration { "macosx", "gmake" }
			toolset "clang"

		configuration { "solaris" }
			linkoptions { "-Wl,--export-dynamic" }

		configuration "aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }


	-- optional 3rd party libraries
	group "contrib"
		if not _OPTIONS["no-zlib"] then
			include "contrib/zlib"
			include "contrib/libzip"
		end
		if not _OPTIONS["no-curl"] then
			include "contrib/curl"
		end


--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
