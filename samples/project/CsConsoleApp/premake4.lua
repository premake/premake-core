project "CsConsoleApp"

	kind     "ConsoleApp"
	language "C#"
	
	files   { "**.cs", "**.bmp", "**.resx", "**.config" }
	
	libdirs { "../lib" }
	links { "CsSharedLib", "CppSharedLib", "System" }

	buildoptions { "/define:TEST" }
		
	configuration "*.bmp"
		buildaction "Embed"
