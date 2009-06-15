solution "PremakeTestbox"
	configurations { "Debug", "Release" }
	
	location "build"
	
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
	
	if _ACTION ~= "codeblocks" and _ACTION ~= "codelite" then
--		include "CsSharedLib"
--		include "CsConsoleApp"
	end
	


-- add to the built-in clean action

	if _ACTION == "clean" then
		os.rmdir("bin")
	end



-- add a new install action

	newaction {
		trigger     = "install",
		description = "Install the project",
		execute     = function ()
			os.copyfile("premake4.lua", "../premake4.lua")
		end
	} 

