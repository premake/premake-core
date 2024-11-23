project "zip-lib"
	language    "C"
	kind        "StaticLib"
	includedirs "include"
	defines     { "N_FSEEKO" }
	warnings    "off"

	files
	{
		"**.h",
		"**.c"
	}

	filter "toolset:gcc or clang or cosmocc"
		defines { "HAVE_SSIZE_T_LIBZIP", "HAVE_CONFIG_H" }
		forceincludes { "unistd.h" }

	filter "system:windows"
		defines { "_WINDOWS" }
	filter { "system:windows", "toolset:mingw" }
		defines { "HAVE_SSIZE_T_LIBZIP" }

	filter "system:macosx"
		defines { "HAVE_SSIZE_T_LIBZIP" }
		forceincludes { "unistd.h" }
