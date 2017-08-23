project "luashim-lib"
	language    "C"
	kind        "StaticLib"
	warnings    "extra"
	pic         "on"

	includedirs { "../lua/src" }

	files
	{
		"*.c",
		"*.h",
		"*.lua"
	}

	filter "system:linux or bsd or hurd or aix"
		defines      { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }

	filter "system:macosx"
		defines      { "LUA_USE_MACOSX" }
