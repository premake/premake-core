project "lua-lib"
	language    "C"
	kind        "StaticLib"
	warnings    "off"

	includedirs { "src" }

	files
	{
		"**.h",
		"**.c"
	}

	excludes
	{
		"src/lua.c",
		"src/luac.c",
		"src/print.c",
	}

	filter "system:linux or bsd or hurd or aix or solaris or haiku"
		defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }

	filter "system:macosx"
		defines     { "LUA_USE_MACOSX" }
