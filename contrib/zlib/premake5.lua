project "zlib-lib"
	language    "C"
	kind        "StaticLib"
	defines     { "N_FSEEKO" }
	warnings    "off"

	files
	{
		"**.h",
		"**.c"
	}

	configuration "windows"
		defines {"_WINDOWS"}
