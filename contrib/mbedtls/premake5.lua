project "mbedtls-lib"
	language    "C"
	kind        "StaticLib"
	warnings    "off"

	includedirs { 'include' }

	if not _OPTIONS["no-zlib"] then
		defines     { 'MBEDTLS_ZLIB_SUPPORT' }
		includedirs { '../zlib' }
	end

	files
	{
		"include/**.h",
		"library/*.c"
	}


