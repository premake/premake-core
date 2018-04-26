--
-- Premake 5.x build configuration script
-- Use this script to configure the project with Premake4.
--

--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to
-- worry about the /scripts argument and all that.
--

	solution "Premake5"
		configurations { "Release", "Debug" }
		location ( _OPTIONS["to"] )

	project "Premake5"
		targetname  "premake5"
		language    "C"
		kind        "ConsoleApp"
		defines     { "PREMAKE_NO_BUILTIN_SCRIPTS" }
		flags       { "No64BitChecks", "ExtraWarnings", "StaticRuntime" }
		includedirs { "contrib/lua/src" }

		files
		{
			"*.txt", "**.lua",
			"contrib/lua/src/*.c", "contrib/lua/src/*.h",
			"src/host/*.c"
		}

		excludes
		{
			"contrib/lua/src/lauxlib.c",
			"contrib/lua/src/lua.c",
			"contrib/lua/src/luac.c",
			"contrib/lua/src/print.c",
			"contrib/lua/**.lua",
			"contrib/lua/etc/*.c"
		}

		configuration "Debug"
			targetdir   "bin/debug"
			defines     "_DEBUG"
			flags       { "Symbols" }

		configuration "Release"
			targetdir   "bin/release"
			defines     "NDEBUG"
			flags       { "OptimizeSize" }

		configuration "vs*"
			defines     { "_CRT_SECURE_NO_WARNINGS" }

		configuration "vs2005"
			defines	{"_CRT_SECURE_NO_DEPRECATE" }

		configuration "windows"
			links { "ole32", "advapi32" }

		configuration "linux or bsd or hurd"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }
			linkoptions { "-rdynamic" }

		configuration "linux or hurd"
			links       { "dl", "rt" }

		configuration "macosx"
			defines     { "LUA_USE_MACOSX" }
			links       { "CoreServices.framework" }

		configuration { "macosx", "gmake" }
			-- toolset "clang"  (not until a 5.0 binary is available)
			buildoptions { "-mmacosx-version-min=10.4" }
			linkoptions  { "-mmacosx-version-min=10.4" }

		configuration { "solaris" }
			links       { "m", "socket", "nsl" }

		configuration "aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }


--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end



--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--

	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}



--
-- This new embed action is slightly hardcoded for the 4.x executable, and is
-- really only intended to get folks bootstrapped on to 5.x
--

	newaction {
		trigger = "embed",
		description = "Embed scripts in scripts.c; required before release builds",
		execute = function ()
			_MAIN_SCRIPT_DIR = os.getcwd()
			_SCRIPT_DIR = path.join(_MAIN_SCRIPT_DIR, "scripts")
			dofile("scripts/embed.lua")
		end
	}
