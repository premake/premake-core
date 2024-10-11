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
		trigger = "docs-check",
		description = "Validates documentation files for Premake APIs",
		execute = function ()
			include (path.join(corePath, "scripts/docscheck.lua"))
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
		trigger = "test-all",
		description = "Run all unit tests, including slower network and I/O"
	}


	newoption {
		trigger = "test-only",
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
		description = "Embed scripts as bytecode instead of stripped source code"
	}

	newoption {
		trigger = "arch",
		value = "arch",
		description = "Set the architecture of the binary to be built.",
		allowed = {
			{ "ARM", "ARM (On macOS, same as ARM64.)" },
			{ "ARM64", "ARM64" },
			{ "x86", "x86 (On macOS, same as x86_64.)" },
			{ "x86_64", "x86_64" },
			{ "Universal", "Universal Binary (macOS only)" },
			--
			{ "Win32", "Same as x86" },
			{ "x64", "Same as x86_64" },
		},
		-- "Generates default platforms for targets, x86 and x86_64 projects for Windows." }
		default = nil,
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

		flags { "MultiProcessorCompile" }
		warnings "Extra"

		if not _OPTIONS["no-zlib"] then
			defines { "PREMAKE_COMPRESSION" }
		end

		if not _OPTIONS["no-curl"] then
			defines { "CURL_STATICLIB", "PREMAKE_CURL"}
		end

		filter { "system:macosx", "options:arch=ARM or arch=ARM64" }
			buildoptions { "-arch arm64" }
			linkoptions { "-arch arm64" }

		filter { "system:macosx", "options:arch=x86 or arch=x86_64 or arch=Win32 or arch=x64" }
			buildoptions { "-arch x86_64" }
			linkoptions { "-arch x86_64" }

		filter { "system:macosx", "options:arch=Universal" }
			buildoptions { "-arch arm64", "-arch x86_64" }
			linkoptions { "-arch arm64", "-arch x86_64" }

		filter { "system:windows", "options:arch=ARM" }
			platforms { "ARM" }

		filter { "system:windows", "options:arch=ARM64" }
			platforms { "ARM64" }

		filter { "system:windows", "options:arch=x86 or arch=Win32" }
			platforms { "Win32" }

		filter { "system:windows", "options:arch=x86_64 or arch=x64" }
			platforms { "x64" }

		filter { "system:windows", "options:not arch" }
			platforms { "x86", "x64" }

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
			flags       { "NoIncrementalLink" }

		-- MinGW AR does not handle LTO out of the box and need a plugin to be setup
		filter { "system:windows", "configurations:Release", "toolset:not mingw" }
			flags		{ "LinkTimeOptimization" }

		filter { "system:uwp" }
			systemversion "latest:latest"
			consumewinrtextension "false"

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
			links       { "ole32", "ws2_32", "advapi32", "version" }
			files { "src/**.rc" }

		filter "toolset:mingw"
			links		{ "crypt32", "bcrypt" }

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

		filter { "system:linux", "toolset:not cosmocc" }
			links		{ "uuid" }

		filter { "system:macosx", "action:gmake" }
			toolset "clang"

		filter { "system:solaris" }
			links       { "m", "socket", "nsl" }

		filter "system:aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }

		filter "system:haiku"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN", "_BSD_SOURCE" }
			links       { "network", "bsd" }

if premake.action.supports("None") then
	project "Web"
		kind "None"

		files "website/**"

	project "Github"
		kind "None"

		files ".github/**"
end
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

	if _OPTIONS["cc"] ~= "cosmocc" then
		group "Binary Modules"
			include "binmodules/example"

			if not _OPTIONS["no-luasocket"] then
				include "binmodules/luasocket"
			end
	end
--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
