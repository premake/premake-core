Root = path.getabsolute(".")

if (_ACTION == nil) then
	return
end

LocationDir = path.join(Root, "project", _ACTION)
TargetdirRoot = path.join(Root, "obj" , _ACTION)

workspace "SampleTest"
	location ( LocationDir )
	configurations { "Debug", "Release"}

	objdir(path.join(Root, "obj" , _ACTION)) -- premake adds $(configName)/$(AppName)
	filter "configurations:Debug"
		optimize "Off"
		symbols "On"
		defines "DEBUG"
	filter "configurations:Release"
		optimize "On"
		symbols "Off"
		defines "NDEBUG"

	filter "action:codelite"
		toolset "gcc"

	filter "system:windows"
		defines "WIN32"
--[[
project "sharedLib"
	kind "SharedLib"
	cppdialect "C++14"
	
	files { path.join(Root, "src/sharedLib/**.cpp"), path.join(Root, "src/sharedLib/**.h") }


project "staticLib"
	kind "StaticLib"
	cppdialect "C++14"
	

	files { path.join(Root, "src/staticLib/**.cpp"), path.join(Root, "src/staticLib/**.h") }
--]]
project "app"
	kind "ConsoleApp"
	cppdialect "C++14"

	files { path.join(Root, "src/app/**.cpp"), path.join(Root, "src/app/**.h") }

	sysincludedirs {path.join(Root, "src/sysinclude")}
	includedirs {path.join(Root, "src/include")}

	--links { "sharedLib", "staticLib"}
