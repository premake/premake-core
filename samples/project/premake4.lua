solution "PremakeTestbox"
	configurations { "Debug", "Release" }
	
	location "build"
	
	configuration "Debug"
		targetdir "bin/debug"
		flags   { "Symbols" }
		defines { "_DEBUG", "DEBUG" }
		
	configuration "Release"
		targetdir "bin/release"
		flags   { "Optimize" }
		defines { "NDEBUG" }
	
	
include "CppConsoleApp"
include "CppWindowedApp"
include "CppSharedLib"
include "CppStaticLib"

function onclean()
	os.rmdir("bin")
	os.rmdir("CppSharedLib/lib")
	os.rmdir("CppStaticLib/lib")
end

