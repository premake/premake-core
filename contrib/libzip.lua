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

	filter "system:linux or macosx"
		defines { "HAVE_SSIZE_T_LIBZIP" }
		excludes {
			"libzip/lib/zip_source_win32a.c",
			"libzip/lib/zip_source_win32w.c",
			"libzip/lib/zip_source_win32utf8.c",
			"libzip/lib/zip_source_win32handle.c"
		}

	filter "system:windows"
		defines { "HAVE_CONFIG_H", "_WINDOWS" }
		excludes {
			"libzip/lib/zip_source_file.c"
		}
