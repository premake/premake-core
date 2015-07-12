project "curl-lib"
	language    "C"
	kind        "StaticLib"
	includedirs {"include", "lib"}
	defines     {"BUILDING_LIBCURL", "CURL_STATICLIB", "CURL_HTTP_ONLY", "CURL_DISABLE_LDAP" }
	flags       { "StaticRuntime" }
	location    "build"

	files 
	{
		"**.h",
		"**.c"
	}
	
	configuration { 'windows' }
		defines {"WIN32"}

	configuration { 'linux' }
		defines {"HAVE_CONFIG_H", "CURL_HIDDEN_SYMBOLS"}

	configuration { 'macosx' }
		defines { 'HAVE_CONFIG_H' }	

	configuration "Release"
		defines {"NDEBUG"}
		flags   { "OptimizeSize" }

	configuration "Debug"
		defines {"_DEBUG"}		
		flags   { "Symbols" }	
