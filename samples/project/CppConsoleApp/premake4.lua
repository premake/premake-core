project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	files    "*.cpp"
	
	libdirs { "../lib" }
	links   { "CppSharedLib" }
