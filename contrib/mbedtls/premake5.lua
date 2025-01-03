project "mbedtls-lib"
	language    "C"
	kind        "StaticLib"
	warnings    "off"

	includedirs { 'include' }

	files
	{
		"include/**.h",
		"library/*.c",
	}
