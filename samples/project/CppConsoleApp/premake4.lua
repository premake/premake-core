project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	flags    { "FatalWarnings", "ExtraWarnings" }
	
	files    { "*.cpp" }
	
	includedirs { "I:/Code" }

	libdirs { "../lib" }
	links   { "CppSharedLib" }
