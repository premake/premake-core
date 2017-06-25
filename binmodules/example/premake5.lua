project "example"
	language     "C"
	kind         "SharedLib"
	warnings     "extra"

	includedirs { 
		"../../contrib/lua/src",
		"../../contrib/luashim"
	}

	links { 'luashim-lib' }

	files
	{
		"*.c",
		"*.lua"
	}

	filter "system:not windows"
		targetprefix    ""
		targetextension ".so"
		pic             "on"

	filter "configurations:Release"
		targetdir "../../bin/release"

	filter "configurations:Debug"
		targetdir "../../bin/debug"
