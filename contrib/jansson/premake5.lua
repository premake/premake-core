project "jansson-lib"
	language    "C"
	kind        "StaticLib"
	includedirs "."
	defines     {"N_FSEEKO", "_CRT_SECURE_NO_DEPRECATE", "HAVE_STDINT_H=1"}
	flags       { "StaticRuntime" }
	location    "build"

	files 
	{
		"**.h",
		"**.c"
	}

	configuration "windows"
		defines {"_WINDOWS"}

	configuration "Release"
		defines {"NDEBUG"}
		flags   { "OptimizeSize" }

	configuration "Debug"
		defines {"_DEBUG"}
		flags   { "Symbols" }
