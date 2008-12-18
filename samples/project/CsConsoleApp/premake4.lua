project "CsConsoleApp"

	kind     "ConsoleApp"
	language "C#"
	
	files   { "**.cs", "**.bmp", "**.resx", "**.config" }
	
	libdirs { "../lib" }
	links { "CsSharedLib", "CppSharedLib", "System" }
	
	configuration "*.bmp"
		buildaction "Embed"
