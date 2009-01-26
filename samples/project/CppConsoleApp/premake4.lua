project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	files    { "*.cpp", "../fakefile.cpp" }
	
	includedirs { "I:/Code" }

	libdirs { "../lib" }
	links   { "CppSharedLib" }
