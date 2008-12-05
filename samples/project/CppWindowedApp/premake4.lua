project "CppWindowedApp"

	kind     "WindowedApp"
	language "C++"
	
	files    "*.cpp"
	
	libdirs { "../lib" }
	links   { "CppStaticLib" }
	
	configuration "windows"
		links { "user32", "gdi32" }

