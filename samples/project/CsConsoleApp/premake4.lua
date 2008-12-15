project "CsConsoleApp"

	kind     "ConsoleApp"
	language "C#"
	
	files   { "*.cs", "*.bmp", "App.config", "Resources.resx" }
	
	libdirs { "../lib" }
	links { "CsSharedLib", "CppSharedLib", "System" }
	
	configuration "Crate.bmp"
		buildaction "Embed"
