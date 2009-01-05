project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	files    "*.cpp"
	
	includedirs { "I:/Code" }
	
	libdirs { "../lib" }
	links   { "CppSharedLib" }
