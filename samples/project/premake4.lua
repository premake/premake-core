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

function onclean()
	os.rmdir("bin")
	os.rmdir("CppSharedLib/lib")
	os.rmdir("CppStaticLib/lib")
	os.rmdir("CsSharedLib/lib")
end

