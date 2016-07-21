project "zip-lib"
	language    "C"
	kind        "StaticLib"
	includedirs { "config/libzip", "libzip/lib", "zlib" }
	defines     { "N_FSEEKO" }
	warnings    "off"

	files
	{
		"libzip/lib/*.h",
		"libzip/lib/*.c",
		"config/libzip/*.h"
	}

	defines { "HAVE_CONFIG_H" }

	filter "system:windows"
		defines { "HAVE_CONFIG_H", "_WINDOWS" }
		excludes {
			"libzip/lib/zip_source_file.c"
		}
