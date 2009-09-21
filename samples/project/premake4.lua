solution "PremakeTestbox"
	configurations { "Debug", "Release" }
	
-- solution level configuration
	
	configuration "Debug"
		targetdir "bin/debug"
		flags   { "Symbols" }
		defines { "_DEBUG", "DEBUG" }
		
	configuration "Release"
		targetdir "bin/release"
		flags   { "Optimize" }
		defines { "NDEBUG" }
			

-- include all the projects
	
	include "CppConsoleApp"
	include "CppWindowedApp"
	include "CppSharedLib"
	include "CppStaticLib"

	if premake.action.supports(premake.action.current(), "C#") then
		include "CsSharedLib"
		include "CsConsoleApp"
	end
	


-- add a new install action

	newaction {
		trigger     = "install",
		description = "Install the project",
		execute     = function ()
			os.copyfile("premake4.lua", "../premake4.lua")
		end
	} 

