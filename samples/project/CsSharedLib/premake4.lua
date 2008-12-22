project "CsSharedLib"

	kind     "SharedLib"
	language "C#"
	files    { "*.cs" }

	configuration "Debug"
		targetdir "lib/debug"
		
	configuration "Release"
		targetdir "lib/release"


	if _ACTION == "clean" then
		os.rmdir("lib")
	end