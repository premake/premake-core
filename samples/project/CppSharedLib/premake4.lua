project "CppSharedLib"

	kind     "SharedLib"
	language "C++"
	files    { "*.cpp", "CppSharedLib.def" }
	
	configuration "Debug"
		targetdir "lib/debug"
		
	configuration "Release"
		targetdir "lib/release"

	
	if _ACTION == "clean" then
		os.rmdir("lib")
	end