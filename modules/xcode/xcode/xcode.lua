--
-- _xcode.lua
-- Define the Apple XCode action and support functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--




	premake.xcode = { }
	local api = premake.api

---
---
	api.register {
		name = "xcodebuildsettings",
		scope = "config",
		kind = "key-array",
	}
	
	api.register {
		name = "xcodebuildresources",
		scope = "config",
		kind = "list",
	}	
	
---
---

	dofile("xcode_common.lua")
	dofile("xcode4_workspace.lua")
	dofile("xcode_project.lua")
	

	newaction 
	{
		trigger         = "xcode4",
		shortname       = "Xcode 4",
		description     = "Generate Apple Xcode 4 project files",
		os              = "macosx",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "SharedLib", "StaticLib", "Makefile", "None" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = 
		{
			cc     = { "gcc" , "clang"},
		},

		valid_platforms = 
		{ 
			Native = "Native", 
			x32 = "Native 32-bit", 
			x64 = "Native 64-bit", 
			Universal32 = "32-bit Universal", 
			Universal64 = "64-bit Universal", 
			Universal = "Universal",			
		},
		
		default_platform = "Universal",
		
		onsolution = function(sln)
			premake.generate(sln, ".xcworkspace/contents.xcworkspacedata", premake.xcode4.workspace_generate)
		end,
		
		onproject = function(prj)
			premake.generate(prj, ".xcodeproj/project.pbxproj", premake.xcode.project)
		end,
		
		oncleanproject = function(prj)
			--premake.clean.directory(prj, "%.xcodeproj")
			--premake.clean.directory(prj, "%.xcworkspace")
		end,

		oncleansolution = function(sln)

		end,
		
		oncleantarget   = function()
		
		end,
 
		
		oncheckproject = function(prj)
			-- Xcode can't mix target kinds within a project
			local last
			for cfg in project.eachconfig(prj) do
				if last and last ~= cfg.kind then
					error("Project '" .. prj.name .. "' uses more than one target kind; not supported by Xcode", 0)
				end
				last = cfg.kind
			end
		end,
	}
