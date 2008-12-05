project "CppStaticLib"

	kind     "StaticLib"
	language "C++"
	files    { "*.cpp" }

	configuration "Debug"
		targetdir "lib/debug"
		
	configuration "Release"
		targetdir "lib/release"
