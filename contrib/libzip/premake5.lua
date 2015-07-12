project "zip-lib"
	language    "C"
	kind        "StaticLib"
	includedirs "include"
	defines     {"N_FSEEKO", "_CRT_SECURE_NO_DEPRECATE"}
	flags       { "StaticRuntime" }
	location    "build"

	files 
	{
		"**.h",
		"**.c"
	}

	configuration "linux"
		defines {"HAVE_SSIZE_T_LIBZIP", "HAVE_CONFIG_H"}

	configuration "windows"
		defines {"_WINDOWS"}

	configuration "macosx"
		defines { 'HAVE_SSIZE_T_LIBZIP' }

	configuration "Release"
		defines {"NDEBUG"}
		flags   { "OptimizeSize" }

	configuration "Debug"
		defines {"_DEBUG"}		
		flags   { "Symbols" }	
