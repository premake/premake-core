--
-- _xcode.lua
-- Define the Apple XCode action and support functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	newaction 
	{
		trigger         = "xcode3",
		shortname       = "Xcode 3",
		description     = "Apple Xcode 3",
		os              = "macosx",

		valid_kinds     = { "ConsoleApp" },
		
		valid_languages = { "C" },
		
		valid_tools     = {
			cc     = { "gcc" },
		},

		onsolution = function(sln)
		end,
		
		onproject = function(prj)
		end,
		
		oncleansolution = function(sln)
		end,
		
		oncleanproject = function(prj)
		end
	}
