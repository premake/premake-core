---------------------------------------------------------------------------
-- Premake4 solution script for Premake4
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
---------------------------------------------------------------------------

solution "Premake4"
	
	configurations { "Debug", "Release" }


project "Premake4"

	language "c"	
	defines { "_CRT_SECURE_NO_WARNINGS" }
	files { "**.h", "**.c" }

	configuration "Debug"
		defines { "_DEBUG" }
		
	configuration "Release"
		defines { "NDEBUG" }
