project "curl-lib"
	language    "C"
	kind        "StaticLib"
	includedirs {"include", "lib"}
	defines     {"BUILDING_LIBCURL", "CURL_STATICLIB", "HTTP_ONLY", "CURL_DISABLE_LDAP" }
	flags       { "StaticRuntime" }
	location    "build"

	files 
	{
		"**.h",
		"**.c"
	}
	
	configuration { 'windows' }
		defines {"WIN32"}
		defines {"USE_SSL", "USE_SCHANNEL", "USE_WINDOWS_SSPI"}

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
