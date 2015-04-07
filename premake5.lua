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
		trigger = "release",
		description = "Merges current branch to release; updates version and tags",
		execute = function ()
			include (path.join(corePath, "scripts/release.lua"))
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
		
		configuration "Debug"
			defines     "_DEBUG"
			flags       { "Symbols" }

		configuration "Release"
			defines     "NDEBUG"
			flags       { "OptimizeSize" }

		configuration "vs*"
			defines     { "_CRT_SECURE_NO_WARNINGS" }

		configuration "vs2005"
			defines   {"_CRT_SECURE_NO_DEPRECATE" }
			
		configuration "cygwin"
			--gccprefix "i686-pc-cygwin-"
			defines   { "LUA_USE_POSIX" }

		configuration "linux or bsd or hurd"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }

		configuration "macosx"
			defines     { "LUA_USE_MACOSX" }

		configuration { "macosx", "gmake" }
			toolset "clang"
			buildoptions { "-mmacosx-version-min=10.4" }
			linkoptions  { "-mmacosx-version-min=10.4" }

		configuration "aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }

		configuration {}

	project "Premake5"
		targetname  "premake5"
		language    "C"
		kind        "ConsoleApp"
		flags       { "No64BitChecks", "ExtraWarnings", "StaticRuntime" }
		includedirs { "src/host/lua-5.1.4/src" }

		files
		{
			"*.txt", "**.lua",
			"src/**.h", "src/**.c",
			"src/host/scripts.c"
		}

		excludes
		{
			"src/host/lua-5.1.4/src/lauxlib.c",
			"src/host/lua-5.1.4/src/lua.c",
			"src/host/lua-5.1.4/src/luac.c",
			"src/host/lua-5.1.4/src/print.c",
			"src/host/lua-5.1.4/**.lua",
			"src/host/lua-5.1.4/etc/*.c"
		}

		configuration "Debug"
			targetdir   "bin/debug"

		configuration "Release"
			targetdir   "bin/release"

		configuration "windows"
			links { "ole32" }
			
		configuration "cygwin"
			includedirs ( "/usr/include/uuid" )
			links       { "uuid" }

		configuration "linux or bsd or hurd"
			includedirs ( "/usr/include/uuid" ) -- pkg-config uuid --cflags --libs 
			links       { "m", "uuid" }
			linkoptions { "-rdynamic" }

		configuration "linux or hurd"
			links       { "dl" }

		configuration "macosx"
			links       { "CoreServices.framework" }

		configuration { "solaris" }
			includedirs ( "/usr/include/uuid" )
			linkoptions { "-Wl,--export-dynamic" }

		configuration "aix"
			includedirs ( "/usr/include/uuid" )
			links       { "m" }

		configuration {}

--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
