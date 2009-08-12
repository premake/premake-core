project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	flags    { "FatalWarnings", "ExtraWarnings" }
	
	files    { "*.h", "*.cpp" }
	
	includedirs { "I:/Code" }

	libdirs { "../lib" }
	links   { "CppSharedLib" }
	
	configuration "Debug"
		targetdir "../bin/debug (x64)"
		links { "CppStaticLib" }
		
	configuration "Release"
		targetdir "../bin/release (x64)"