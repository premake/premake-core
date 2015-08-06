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
		defines { "HAVE_CONFIG_H" }

	configuration "windows"
		defines {"_WINDOWS"}

	-- HAX: do we have a way to filter on the MSC toolset?
	filter "action:not vs*"
		defines { "HAVE_SSIZE_T_LIBZIP" }

	configuration "Release"
		defines {"NDEBUG"}
		flags   { "OptimizeSize" }

	configuration "Debug"
		defines {"_DEBUG"}
		flags   { "Symbols" }
