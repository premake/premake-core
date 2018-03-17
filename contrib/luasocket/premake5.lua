project "luasocket-lib"
	language    "C"
	kind        "StaticLib"
	warnings    "extra"
	pic         "on"

	includedirs { "../lua/src" }

	files
	{
		"src/*.c",
		"src/*.h",
		"src/*.lua"
	}

	filter "system:windows"
		removefiles
		{
			"src/serial.c",
			"src/unixdgram.*",
			"src/unixstream.*",
			"src/unix.*",
			"src/usocket.*",
		}
	
	filter "system: not windows"
		removefiles
		{
			"src/wsocket.*",
		}