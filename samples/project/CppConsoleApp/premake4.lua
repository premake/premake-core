project "CppConsoleApp"

	kind     "ConsoleApp"
	language "C++"
	
	flags    { "FatalWarnings", "ExtraWarnings" }
	
	files    { "*.h", "*.cpp" }
	
	includedirs { "I:/Code" }

	libdirs { "../lib" }
	links   { "CppSharedLib" }
	
	pchheader "CppConsoleApp.h"

	configuration "Debug"
		targetdir "../bin/debug (x64)"
		
	configuration "Release"
		targetdir "../bin/release (x64)"