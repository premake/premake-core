--
-- cmdline.lua
-- Functions to define and handle command line actions and options.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	local requiredactionfields =
	{
		"description",
		"trigger",
	}
	
	local requiredoptionfields = 
	{
		"description",
		"trigger"
	}


--
-- Define a new action.
--

	function newaction(a)
		-- some sanity checking
		local missing
		for _, field in ipairs(requiredactionfields) do
			if (not a[field]) then
				missing = field
			end
		end
		
		if (missing) then
			error("action needs a " .. missing, 2)
		end

		-- add it to the master list
		premake.actions[a.trigger] = a		
	end

	
	
--
-- Define a new option.
--

	function newoption(opt)
		-- some sanity checking
		local missing
		for _, field in ipairs(requiredoptionfields) do
			if (not opt[field]) then
				missing = field
			end
		end
		
		if (missing) then
			error("action needs a " .. missing, 2)
		end
		
		-- add it to the master list
		premake.options[opt.trigger] = opt
	end
	
	
	
--
-- Built-in command line options
--

	newoption 
	{
		trigger     = "cc",
		value       = "compiler",
		description = "Choose a C/C++ compiler set",
		allowed = {
			{ "gcc", "GNU GCC compiler (gcc/g++)" },
			{ "ow",  "OpenWatcom compiler"        },
		}
	}

	newoption
	{
		trigger     = "dotnet",
		value       = "value",
		description = "Choose a .NET compiler set",
		allowed = {
			{ "ms",      "Microsoft .NET (csc)" },
			{ "mono",    "Novell Mono (mcs)"    },
			{ "pnet",    "Portable.NET (cscc)"  },
		}
	}

	newoption
	{
		trigger     = "file",
		value       = "filename",
		description = "Process the specified Premake script file"
	}
	
	newoption
	{
		trigger     = "help",
		description = "Display this information"
	}
		
	newoption
	{
		trigger     = "os",
		value       = "value",
		description = "Generate files for a different operating system",
		allowed = {
			{ "bsd",      "OpenBSD, NetBSD, or FreeBSD" },
			{ "linux",    "Linux" },
			{ "macosx",   "Apple Mac OS X" },
			{ "windows",  "Microsoft Windows" },
		}
	}

	newoption
	{
		trigger     = "scripts",
		value       = "path",
		description = "Search for additional scripts on the given path"
	}
	
	newoption
	{
		trigger     = "version",
		description = "Display version information"
	}
	