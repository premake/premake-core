solution "PremakeTestbox"
	configurations { "Debug", "Release" }
	
	configuration "Debug"
		targetdir "bin/debug"
		flags   { "Symbols" }
		defines { "_DEBUG", "DEBUG" }
		
	configuration "Release"
		targetdir "bin/release"
		flags   { "Optimize" }
		defines { "NDEBUG" }
	
	
include "CppConsoleApp"
include "CsConsoleApp"
include "CppWindowedApp"
include "CppSharedLib"
include "CsSharedLib"
include "CppStaticLib"


if _ACTION == "clean" then
	os.rmdir("bin")
end

