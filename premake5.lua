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
			test = require "self-test"
			premake.action.call("self-test")
		end
	}


	newoption {
		trigger     = "test-only",
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
		trigger = "no-luasocket",
		description = "Disable Luasocket 3rd party lib"
	}

	newoption {
		trigger     = "bytecode",
		description = "Embed scripts as bytecode instead of stripped souce code"
	}

--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to
-- worry about the /scripts argument and all that.
--
-- TODO: Switch to these new APIs once they've had a chance to land everywhere
--
--    defaultConfiguration "Release"
--    symbols "On"
--

	solution "Premake5"
		configurations { "Release", "Debug" }
		location ( _OPTIONS["to"] )

		flags { "StaticRuntime", "MultiProcessorCompile" }
		warnings "Extra"

		if not _OPTIONS["no-zlib"] then
			defines { "PREMAKE_COMPRESSION" }
		end
		
		if not _OPTIONS["no-curl"] then
			defines { "CURL_STATICLIB", "PREMAKE_CURL"}
		end

		filter { 'system:windows' }
			platforms   { 'x86', 'x64' }

		filter "configurations:Debug"
			defines     "_DEBUG"
			flags       { "Symbols" }

		filter "configurations:Release"
			defines     "NDEBUG"
			optimize    "Full"
			flags       { "NoBufferSecurityCheck", "NoRuntimeChecks" }

		filter "action:vs*"
			defines     { "_CRT_SECURE_NO_DEPRECATE", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS" }

		filter { "system:windows", "configurations:Release" }
			flags       { "NoIncrementalLink", "LinkTimeOptimization" }

	project "Premake5"
		targetname  "premake5"
		language    "C"
		kind        "ConsoleApp"
		includedirs { "contrib/lua/src", "contrib/luashim" }
		links       { "lua-lib" }

		-- optional 3rd party libraries
		if not _OPTIONS["no-zlib"] then
			includedirs { "contrib/zlib", "contrib/libzip" }
			links { "zip-lib", "zlib-lib" }
		end
		
		if not _OPTIONS["no-curl"] then
			includedirs { "contrib/curl/include" }
			links { "curl-lib" }
		end

		files
		{
			"*.txt", "**.lua",
			"src/**.h", "src/**.c",
			"modules/**"
		}

		excludes
		{
			"contrib/**.*",
			"binmodules/**.*"
		}

		filter "configurations:Debug"
			targetdir   "bin/debug"
			debugargs   { "--scripts=%{prj.location}/%{path.getrelative(prj.location, prj.basedir)}", "test" }
			debugdir    "."

		filter "configurations:Release"
			targetdir   "bin/release"

		filter "system:windows"
			links       { "ole32", "ws2_32", "advapi32" }

		filter "system:linux or bsd or hurd"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }
			linkoptions { "-rdynamic" }

		filter "system:linux or hurd"
			links       { "dl", "rt" }

		filter { "system:not windows", "system:not macosx" }
			if not _OPTIONS["no-curl"] then
				links   { "mbedtls-lib" }
			end

		filter "system:macosx"
			defines     { "LUA_USE_MACOSX" }
			links       { "CoreServices.framework", "Foundation.framework", "Security.framework", "readline" }

		filter { "system:macosx", "action:gmake" }
			toolset "clang"

		filter { "system:solaris" }
			links       { "m", "socket", "nsl" }

		filter "system:aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }


	-- optional 3rd party libraries
	group "contrib"
		include "contrib/lua"
		include "contrib/luashim"
		
		if not _OPTIONS["no-zlib"] then
			include "contrib/zlib"
			include "contrib/libzip"
		end
		
		if not _OPTIONS["no-curl"] then
			include "contrib/mbedtls"
			include "contrib/curl"
		end		

	group "Binary Modules"
		include "binmodules/example"
		
		if not _OPTIONS["no-luasocket"] then
			include "binmodules/luasocket"
		end

--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
